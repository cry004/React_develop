require 'test_helper'

class TaskUtils::WorksheetsTaskTest < ActiveSupport::TestCase
  let(:bucket) { 'my-try-syutoku-ans' }
  let(:directory_name) { bucket.sub(/\Amy-try-/, '') }
  let(:category) { directory_name.split('-').first }
  let(:type) { 'answer' }

  let(:object_keys) do
    [
      "#{directory_name}/#{schoolyear}/english_regular/",
      pdf_url,
    ]
  end

  let(:filename) { 'eng_001' }
  let(:video_filename) { "#{filename}.mp4" }

  let(:schoolyear) { 'c1' }

  let(:pdf_url) { "#{directory_name}/#{schoolyear}/english_regular/#{filename}_#{category}_ans.pdf" }
  let(:full_pdf_url) { "https://s3-ap-northeast-1.amazonaws.com/#{bucket}/#{pdf_url}" }

  # HACK: Convert strings to symbol on fixtures if possible
  let(:hash_worksheet) do
    {
      category: category,
      type: type,
      url: full_pdf_url
    }
  end

  let(:video) { Video.find_by!(filename: video_filename) }
  let(:worksheet) { Worksheet.find_by!(url: full_pdf_url) }

  let(:videos) { Video.where(filename: video_filenames) }
  let(:worksheets) { Worksheet.where(url: full_pdf_urls) }

  let(:hash_video_worksheet) do
    {
      video_id: video.id,
      worksheet_id: worksheet.id
    }
  end

  let(:video_filenames) { [ video_filename ] }
  let(:pdf_urls) { [ pdf_url ] }
  let(:full_pdf_urls) { [ full_pdf_url ] }

  let(:hash_worksheets) { [ hash_worksheet ] }
  let(:hash_video_worksheets) { [ hash_video_worksheet ] }

  let(:additional_pdf_url) { pdf_url.sub(/english/, 'mathematics') }
  let(:additional_pdf_urls) { [ additional_pdf_url ] }

  let(:remote_pdf_urls) do
    [
      pdf_url,
      additional_pdf_url
    ]
  end

  let(:local_pdf_urls) { pdf_urls }

  describe '.execute' do
    subject { TaskUtils::WorksheetsTask.execute }
    it 'calls create_worksheets_and_video_worksheet_with(bucket)' do
      called = false
      proc = -> (bucket) { called = true }
      TaskUtils::WorksheetsTask.stub(:create_worksheets_and_video_worksheet_with, proc) do
        subject
      end
      assert(called)
    end
  end

  # NOTE: private methods

  # HACK
  describe 'create_worksheets_and_video_worksheet_with(bucket)' do
    subject { TaskUtils::WorksheetsTask.send(:create_worksheets_and_video_worksheet_with, bucket) }

    it 'calls import_worksheets_from(pdf_urls, bucket)' do
      proc = -> (bucket) { additional_pdf_urls }
      TaskUtils::WorksheetsTask.stub(:additional_pdf_urls_with, proc) do
        proc = -> (additional_pdf_urls, bucket) {}
        TaskUtils::WorksheetsTask.stub(:import_video_worksheets_from, proc) do
          called = false
          proc = -> (additional_pdf_urls, bucket) { called = true }
          TaskUtils::WorksheetsTask.stub(:import_worksheets_from, proc) do
            subject
          end
          assert(called)
        end
      end
    end

    it 'calls import_video_worksheets_from(pdf_urls, bucket)' do
      proc = -> (bucket) { additional_pdf_urls }
      TaskUtils::WorksheetsTask.stub(:additional_pdf_urls_with, proc) do
        proc = -> (additional_pdf_urls, bucket) {}
        TaskUtils::WorksheetsTask.stub(:import_worksheets_from, proc) do
          called = false
          proc = -> (additional_pdf_urls, bucket) { called = true }
          TaskUtils::WorksheetsTask.stub(:import_video_worksheets_from, proc) do
            subject
          end
          assert(called)
        end
      end
    end
  end

  describe '.additional_pdf_urls_with(bucket)' do
    subject { TaskUtils::WorksheetsTask.send(:additional_pdf_urls_with, bucket) }

    it 'returns additional pdf urls' do
      proc = -> (bucket) { object_keys }
      TaskUtils::WorksheetsTask.stub(:get_object_keys_from_s3, proc) do
        proc = -> (object_keys) { remote_pdf_urls }
        TaskUtils::WorksheetsTask.stub(:pdf_urls_from, proc) do
          proc = -> (remote_pdf_urls, bucket) { additional_pdf_urls }
          TaskUtils::WorksheetsTask.stub(:additional_pdf_urls_from, proc) do
            assert_equal additional_pdf_urls, subject
          end
        end
      end
    end
  end

  # HACK: Remove 'get_' , '_s3' from method name
  describe '.get_object_keys_from_s3(bucket)' do
    subject { TaskUtils::WorksheetsTask.send(:get_object_keys_from_s3, bucket) }

    describe 'when bucket is my-try-ensyu-ans' do
      let(:bucket) { 'my-try-ensyu-ans' }

      # HACK: Remove cassette 'aws_s3_list_ensyu_pdf_files'
      before { VCR.insert_cassette 'aws_s3_list_ensyu_ans_pdf_files' }
      after { VCR.eject_cassette }

      # OPTIMIZE: Improve performance
      it 'includes the last object which has ensyu-ans and k_center' do
        assert_includes subject.last, "#{directory_name}/k_center/"
      end
    end

    describe 'when bucket is my-try-syutoku-ans' do
      let(:bucket) { 'my-try-syutoku-ans' }

      # HACK: Remove cassette 'aws_s3_list_syutoku_pdf_files'
      before { VCR.insert_cassette 'aws_s3_list_syutoku_ans_pdf_files' }
      after { VCR.eject_cassette }

      # OPTIMIZE: Improve performance
      it 'includes object which has syutoku-ans and k_center' do
        assert_includes subject.last, "#{directory_name}/k_center/"
      end
    end
  end

  describe '.pdf_urls_from(object_keys)' do
    subject { TaskUtils::WorksheetsTask.send(:pdf_urls_from, object_keys) }

    it 'returns only pdf urls' do
      assert_equal pdf_urls, subject
    end
  end

  describe '.additional_pdf_urls_from(pdf_urls, bucket)' do
    subject { TaskUtils::WorksheetsTask.send(:additional_pdf_urls_from, remote_pdf_urls, bucket) }

    it 'returns additional pdf urls' do
      proc = -> (pdf_urls, bucket) { local_pdf_urls }
      TaskUtils::WorksheetsTask.stub(:existing_pdf_urls_from, proc) do
        assert_equal additional_pdf_urls, subject
      end
    end
  end

  describe '.existing_pdf_urls' do
    subject { TaskUtils::WorksheetsTask.send(:existing_pdf_urls_from, pdf_urls, bucket) }

    it 'returns existing pdf urls' do
      sym_url = :url
      proc = -> (sym_url) { full_pdf_urls }
      Worksheet.stub(:pluck, proc) do
        assert_equal local_pdf_urls, subject
      end
    end
  end

  describe '.import_worksheets_from(pdf_urls, bucket)' do
    subject { TaskUtils::WorksheetsTask.send(:import_worksheets_from, pdf_urls, bucket) }

    it 'calls Worksheet.import(worksheets)' do
      proc = -> (pdf_urls, bucket) { hash_worksheets }
      TaskUtils::WorksheetsTask.stub(:prepare_worksheets_from, proc) do
        called = false
        proc = -> (hash_worksheets) { called = true }
        Worksheet.stub(:import!, proc) do
          subject
        end
        assert(called)
      end
    end
  end

  describe '.import_video_worksheets_from(pdf_urls, bucket)' do
    subject { TaskUtils::WorksheetsTask.send(:import_video_worksheets_from, pdf_urls, bucket) }
    it 'calls VideoWorksheet.import(video_worksheets)' do
      proc = -> (pdf_urls, bucket) { hash_video_worksheets }
      TaskUtils::WorksheetsTask.stub(:prepare_video_worksheets_from, proc) do
        called = false
        proc = -> (hash_video_worksheets) { called = true }
        VideoWorksheet.stub(:import!, proc) do
          subject
        end
        assert(called)
      end
    end
  end

  describe '.prepare_worksheets_from(pdf_urls, bucket)' do
    subject { TaskUtils::WorksheetsTask.send(:prepare_worksheets_from, pdf_urls, bucket) }

    it 'returns the expected array of hash of worksheet' do
      proc = -> (pdf_url, bucket) { full_pdf_url }
      TaskUtils::WorksheetsTask.stub(:full_pdf_url_from, proc) do
        assert_equal hash_worksheets, subject
      end
    end
  end

  describe '.prepare_video_worksheets_from(pdf_urls, bucket)' do
    subject { TaskUtils::WorksheetsTask.send(:prepare_video_worksheets_from, pdf_urls, bucket) }

    let(:filename) { 'eng_090' }
    let(:schoolyear) { 'c3' }

    let(:hash_video_worksheets) do
      [
        {
          video_id: 93,
          worksheet_id: 4
        },
        {
          video_id: 94,
          worksheet_id: 4
        }
      ]
    end

    it 'returns expected video_worksheets' do
      proc = -> (pdf_urls, bucket) { videos }
      TaskUtils::WorksheetsTask.stub(:find_videos_from, proc) do
        proc = -> (pdf_urls, bucket) { worksheets }
        TaskUtils::WorksheetsTask.stub(:find_worksheets_from, proc) do
          assert_equal hash_video_worksheets, subject
        end
      end
    end
  end

  # HACK: Remove 'find_' from method_name
  describe '.find_worksheet_from(worksheets, video, bucket)' do
    subject { TaskUtils::WorksheetsTask.send(:find_worksheet_from, worksheets, video, bucket) }

    it 'returns the expected worksheet' do
      assert_equal worksheet, subject
    end
  end

  # HACK: Remove 'find_' from method_name
  describe '.find_videos_from(pdf_urls, bucket)' do
    subject { TaskUtils::WorksheetsTask.send(:find_videos_from, pdf_urls, bucket) }

    it 'returns videos' do
      assert(subject.present?)
    end
  end

  describe '.find_worksheets_from(pdf_urls, bucket)' do
    subject { TaskUtils::WorksheetsTask.send(:find_worksheets_from, pdf_urls, bucket) }

    it 'returns worksheets' do
      assert(subject.present?)
    end
  end

  describe '.filename_from(pdf_url, bucket)' do
    subject { TaskUtils::WorksheetsTask.send(:filename_from, pdf_url, bucket) }

    it 'returns an only filename' do
      assert_equal filename, subject
    end
  end

  # HACK: Remove this test because this is worthless
  describe '.get_size_of_video_by(filename)' do
    subject { TaskUtils::WorksheetsTask.send(:get_size_of_video_by, filename) }

    # NOTE: Set a unique constraint to filename on :video if possible
    # NOTE: Remove this test and the method if possible to set a unique constraint
    it 'matches the unique video' do
      proc = -> (filename) { video_filename }
      TaskUtils::WorksheetsTask.stub(:video_filename_from, proc) do
        assert_equal 1, subject
      end
    end
  end

  describe '.video_filename_from(filename)' do
    subject { TaskUtils::WorksheetsTask.send(:video_filename_from, filename) }

    it 'adds the extension of mp4' do
      assert_equal video_filename, subject
    end
  end

  describe '.full_pdf_url_from(pdf_url, bucket)' do
    subject { TaskUtils::WorksheetsTask.send(:full_pdf_url_from, pdf_url, bucket) }

    it 'adds S3_HOST and BUCKET_NAME' do
      assert_equal full_pdf_url, subject
    end
  end

  describe '.pdf_url_from(full_pdf_url, bucket)' do
    subject { TaskUtils::WorksheetsTask.send(:pdf_url_from, full_pdf_url, bucket) }

    it 'returns the expected pdf_url' do
      assert_equal pdf_url, subject
    end
  end

  describe '.bucket_from(full_pdf_url)' do
    subject { TaskUtils::WorksheetsTask.send(:bucket_from, full_pdf_url) }

    it 'returns the expected bucket' do
      assert_equal bucket, subject
    end
  end


  describe '.schoolyear_from(pdf_url)' do
    subject { TaskUtils::WorksheetsTask.send(:schoolyear_from, pdf_url) }
    describe 'without transforming' do
      describe 'when pdf_url starts with c1' do
        let(:schoolyear) { 'c1' }

        it 'returns c1' do
          assert_equal 'c1', subject
        end
      end

      describe 'when pdf_url starts with c2' do
        let(:schoolyear) { 'c2' }

        it 'returns c2' do
          assert_equal 'c2', subject
        end
      end

      describe 'when pdf_url starts with c3' do
        let(:schoolyear) { 'c3' }

        it 'returns c3' do
          assert_equal 'c3', subject
        end
      end

      describe 'when pdf_url starts with k' do
        let(:schoolyear) { 'k' }

        it 'returns k' do
          assert_equal 'k', subject
        end
      end
    end

    describe 'with transforming' do
      describe 'when pdf_url starts with call' do
        let(:schoolyear) { 'call' }

        it 'returns c1' do
          assert_equal 'c1', subject
        end
      end

      describe 'when pdf_url starts with c_highlevel' do
        let(:schoolyear) { 'c_highlevel' }

        it 'returns c' do
          assert_equal 'c', subject
        end
      end

      describe 'when pdf_url starts with k_center' do
        let(:schoolyear) { 'k_center' }
        it 'returns k' do
          assert_equal 'k', subject
        end
      end
    end
  end
end
