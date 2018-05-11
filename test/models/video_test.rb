require 'test_helper'

class VideoTest < ActiveSupport::TestCase
  describe 'return URL of PDF for practices' do
    let(:video) { Video.find_by(schoolyear: schoolyear, subject: subject_record) }
    let(:subject_record) { Subject.find_by(school: school, for_video: true) }

    # FIXME: Break the dependency on notebook_url
    # TODO: Extract `file_path()` from `notebook_url`
    let(:notebook_file_path) { video.notebook_url.sub(Settings.notebook_base_url, '') }
    let(:practice_file_path) { notebook_file_path.sub(video.notebook_filename, video.practice_filename) }

    let(:expected_url) { Settings.practice_base_url + file_path }

    describe '#practice_url' do
      subject { video.practice_url }
      let(:file_path) { practice_file_path }

      describe 'when school is c' do
        let(:school) { 'c' }

        describe 'when schoolyear is c1' do
          let(:schoolyear) { 'c1' }

          it 'returns a valid practice_url for c1' do
            assert_equal expected_url, subject
          end
        end

        describe 'when schoolyear is c2' do
          let(:schoolyear) { 'c2' }

          it 'returns a valid practice_url for c2' do
            assert_equal expected_url, subject
          end
        end
      end

      describe 'when school is k' do
        describe 'when subject is university_exam' do
          let(:subject_record) { Subject.for_university_exam.where(for_video: true).first }
          let(:schoolyear) { 'k' }

          it 'returns lesson text url' do
            assert_equal video.practice_url, video.lesson_text_url
          end
        end
        describe 'when subject is not university_exam' do
          let(:school) { 'k' }
          let(:schoolyear) { 'k' }

          it 'returns nil' do
            assert_nil subject
          end
        end
      end
    end

    describe '#practice_answer_url' do
      subject { video.practice_answer_url }
      let(:file_path) { practice_file_path.sub('.pdf', '_ans.pdf')}

      describe 'when school is c' do
        let(:school) { 'c' }

        describe 'when schoolyear is c1' do
          let(:schoolyear) { 'c1' }

          it 'returns a valid practice_answer_url for c1' do
            assert_equal expected_url, subject
          end
        end

        describe 'when schoolyear is c2' do
          let(:schoolyear) { 'c2' }

          it 'returns a valid practice_answer_url for c1' do
            assert_equal expected_url, subject
          end
        end
      end

      describe 'when school is k' do
        describe 'when subject is university_exam' do
          let(:subject_record) { Subject.for_university_exam.where(for_video: true).first }
          let(:schoolyear) { 'k' }

          it 'returns lesson text url' do
            assert_equal video.practice_answer_url, video.lesson_text_answer_url
          end
        end
        describe 'when subject is not university_exam' do
          let(:school) { 'k' }
          let(:schoolyear) { 'k' }

          it 'returns nil' do
            assert_nil subject
          end
        end
      end
    end
  end

  describe '#notebook_url' do
    subject { video.notebook_url }
    let(:video) { Video.find_by(schoolyear: school_param, subject: subject_record) }
    let(:result) { URI.parse(subject).path.split("/")[1..-1] }

    describe 'when video schoolyear is c1' do
      let(:school_param) { 'c1' }
      describe 'when subject is english exam' do
        let(:subject_record) { Subject.find_by(name: 'english', type: 'exam', school: 'c') }

        it 'return PDF url which includes company name' do
          company_prefix = video.filename.split("_")[2]
          assert_equal ["try-it-notebooks", "notebooks", video.schoolyear, subject_record.full_name, company_prefix, video.filename.gsub(".mp4", "_note_ans.pdf")], result
        end
      end

      describe 'when subject is social_studies' do
        let(:subject_record) { Subject.find_by(name: 'civics', type: 'regular', school: 'c') }

        it 'return PDF url which start call' do
          assert_equal ["try-it-notebooks", "notebooks", "call", subject_record.full_name, video.filename.gsub(".mp4", "_note_ans.pdf")], result
        end
      end

      describe 'when subject is except social_studies and english_exam' do
        let(:subject_record) { Subject.find_by(name: 'english', type: 'regular', school: 'c') }
        it 'return PDF url which start call' do
          assert_equal ["try-it-notebooks", "notebooks", video.schoolyear, subject_record.full_name, video.filename.gsub(".mp4", "_note_ans.pdf")], result
        end
      end
    end

    describe 'when video schoolyear is k' do
      let(:school_param) { 'k' }
      let(:subject_record) { Subject.find_by(school: 'k', for_video: true) }
      it 'return valid notebook url' do
        assert_equal ["try-it-notebooks", "notebooks", video.schoolyear, subject_record.full_name, video.filename.gsub(".mp4", "_note_ans.pdf")], result
      end
    end
  end

  describe '#schoolyear_for_eventlog' do
    subject { video.schoolyear_for_eventlog }
    let(:video) { Video.find_by(subject: subject_param, schoolyear: schoolyear_param) }

    describe 'schoolyear param is c1' do
      let(:schoolyear_param) { 'c1' }
      describe 'subject is english regular' do
        let(:subject_param) { Subject.find_by(name: "english", type: "regular", school: 'c') }
        it 'return c1' do
          assert_equal 'c1', subject
        end
      end
      describe 'subject is civics regular' do
        let(:subject_param) { Subject.find_by(name: "civics", type: "regular", school: 'c') }
        it 'return call' do
          assert_equal 'call', subject
        end
      end
      describe 'subject is civics exam' do
        let(:subject_param) { Subject.find_by(name: "civics", type: "exam", school: 'c') }
        it 'return call' do
          assert_equal 'call', subject
        end
      end
      describe 'subject is geography regular' do
        let(:subject_param) { Subject.find_by(name: "geography", type: "regular", school: 'c') }
        it 'return call' do
          assert_equal 'call', subject
        end
      end
      describe 'subject is geography exam' do
        let(:subject_param) { Subject.find_by(name: "geography", type: "exam", school: 'c') }
        it 'return call' do
          assert_equal 'call', subject
        end
      end
      describe 'subject is history regular' do
        let(:subject_param) { Subject.find_by(name: "history", type: "regular", school: 'c') }
        it 'return call' do
          assert_equal 'call', subject
        end
      end
      describe 'subject is history exam' do
        let(:subject_param) { Subject.find_by(name: "history", type: "exam", school: 'c') }
        it 'return call' do
          assert_equal 'call', subject
        end
      end
    end

    describe 'schoolyear params is k' do
      let(:schoolyear_param) { 'k' }
      let(:subject_param) { Subject.find_by(name: "english", type: "grammar", school: 'k') }

      it 'return k' do
        assert_equal 'k', subject
      end
    end
  end

  describe 'validation' do
    subject { Video.create!(video_params) }

    describe 'lesson_text validation' do
      describe 'lesson_text is nil' do
        let(:video_params) { nil }

        it 'can be create' do
          assert subject
        end
      end

      describe 'lesson_text is valid param' do
        let(:video_params) { { lesson_text: { "range" => { start: 50, end: 100 }, "url" => "http://example.com/test.pdf" } }}
        it 'can be created' do
          assert subject
        end
      end

      describe 'lesson_text is invalid params' do
        describe 'when invalid key' do
          let(:video_params) { { lesson_text: { "range" => { starting: 50, ending: 100 }, "url" => "http://example.com/test.pdf" } }}
          it 'can not created' do
            assert_raise ActiveRecord::RecordInvalid do
              subject
            end
          end
        end
      end
    end
  end

  describe '#chapters_with_index' do
    subject { video.chapters_with_index }
    let(:video) { Video.first }

    it 'should return array of hash(chapter and index)' do
      chapters = video.chapters
      duration = video.duration
      range_check_block = lambda do |hash|
        index = hash[:index]
        if chapters.count == index
          hash[:range] == ((chapters[index - 1]['position'].to_i)..duration)
        else
          hash[:range] == ((chapters[index - 1]['position'].to_i)...chapters[index]['position'].to_i)
        end
      end
      assert_equal((1..video.chapters.count).to_a,
                   subject.map { |s| s[:index] })

      assert(subject.all?(&range_check_block))
    end
  end
end
