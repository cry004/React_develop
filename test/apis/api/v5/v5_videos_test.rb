require 'test_helper'

class API::V5::VideosTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include API::Root.helpers

  def app
    Rails.application
  end

  def setup
    super # Not done without SeedFu
    unless (name.include?('ログイン') || name.include?('login'))
      @current_student = Student.first
      create_access_token
      header 'X-Authorization', "Bearer #{@access_token}"
    end

    @logger = TestLogger.new
    Rails.logger = @logger # Capture log output.
    Rails.logger.formatter = SimpleLogFommater.new # Only message to log output
  end

  def exist_id_star
    video_id = Video.first.id
    Star.create(student_id: @current_student.id, video_id: video_id)
    video_id
  end

  def do_not_exist_id_star
    last_video = Video.last
    return 1 if last_video.blank?

    last_video.id + 1
  end

  def params
    @params ||= {}
  end

  describe 'POST /api/v5/videos/:id/bookmarks' do
    subject { post "/api/v5/videos/#{id}/bookmarks" }
    before { subject }

    describe 'with valid video id' do
      let(:id)  { Video.last.id }

      it 'returns status 201' do
        assert_equal 201, last_response.status
      end
    end

    describe 'with invalid video id' do
      let(:id)  { Video.last.id + 1 }

      it 'returns status 404' do
        assert_equal 404, last_response.status
      end
    end
  end

  describe 'DELETE /api/v5/videos/id/bookmarks' do
    subject { delete "/api/v5/videos/#{id}/bookmarks" }

    describe 'exist bookmark' do
      let(:id) { exist_id_star }
      it 'returns status is 204' do
        subject
        assert_equal 204, last_response.status
      end

      it 'creates valid logs' do
        subject
        log = @logger.messages_to_hash
        assert_equal 'UnstarVideo', log['eventName']
      end
    end

    describe 'do not exist bookmark' do
      let(:id) { do_not_exist_id_star }
      it 'returns status is 404' do
        subject
        assert_equal 404, Oj.load(last_response.body)['meta']['code']
      end
    end
  end

  describe 'POST api/v5/videos/:id/watches' do
    subject { post "/api/v5/videos/#{video.id}/watches", params }

    let(:data) { Oj.load(last_response.body)['data'] }
    before { subject }

    describe 'with valid params' do
      let(:params)  { { viewed_time: 400 } }
      let(:video)   { Video.find(6166) }

      it 'returns status 201' do
        assert_equal 201, last_response.status
      end

      it 'has level node' do
        assert data['level']
      end

      it 'has experience_point node' do
        assert data['experience_point'], 1200
      end

      it 'has unit_name node' do
        assert data['unit_name']
      end

      it 'has trophies_progress node' do
        assert data['trophies_progress']
      end

      it 'has title node' do
        assert data['title']
      end
    end

    describe 'watch completed unit' do
      let(:params)  { { viewed_time: 400 } }
      let(:video)   { Video.find(22) }

      it 'returns 6 trophies completed' do
        assert_equal data['trophies_progress']['completed_trophies_count'], 6
      end

      it 'returns 12 total trophies' do
        assert_equal data['trophies_progress']['total_trophies_count'], 12
      end
    end

    describe 'with valid params viewed time and mark video watched for video longer than 300 seconds' do
      let(:params)  { { viewed_time: 300 } }
      let(:video)   { Video.first }

      it 'returns watched state true' do
        assert VideoViewing.last.watched
      end
    end

    describe 'with valid params viewed time and mark video not watched for video longer than 300 seconds' do
      let(:params)  { { viewed_time: 200 } }
      let(:video)   { Video.first }

      it 'returns watched state false' do
        assert_equal false, VideoViewing.last.watched
      end
    end

    describe 'with valid params viewed time and mark video watched for video shorter than 300 seconds' do
      let(:params)  { { viewed_time: 248 } }
      let(:video)   { Video.find(302) }

      it 'returns watched state true' do
        assert VideoViewing.last.watched
      end
    end

    describe 'with valid params viewed time and mark video not watched for video shorter than 300 seconds' do
      let(:params)  { { viewed_time: 200 } }
      let(:video)   { Video.find(302) }

      it 'returns watched state false' do
        assert_equal false, VideoViewing.last.watched
      end
    end

    describe 'with valid params viewed time and mark unit completed count' do
      let(:params)  { { viewed_time: 400 } }
      let(:video)   { Video.find(102) }

      it 'returns unit_trophy_flag state true and increase trophies count 1' do
        assert_equal 5, @current_student.trophies_count #it's already 4 because of fixture'data
      end
    end

    describe 'with invalid viewed time params' do
      let(:params)  { { viewed_time: 'abc' } }
      let(:video)   { Video.first }

      it 'returns status 400' do
        assert_equal 400, last_response.status
      end
    end

    describe 'with invalid nil params' do
      let(:params)  { {} }
      let(:video)   { Video.first }

      it 'returns status 400' do
        assert_equal 400, last_response.status
      end
    end
  end

  describe 'GET /api/v5/videos/histories' do
    subject { get 'api/v5/videos/histories', params }

    let(:data) { Oj.load(last_response.body)['data'] }

    before { subject }

    describe 'without params' do
      let(:params) { {} }

      it 'returns 200 status' do
        assert last_response.ok?
      end

      it 'has videos node' do
        assert data['videos']
      end

      it 'has video_id' do
        assert data['videos'].first['video_id']
      end
    end

    describe 'with pagination params' do
      let(:params) { { page: page, per_page: per_page } }

      describe 'with no pagination' do
        let(:page)     { 1 }
        let(:per_page) { 20 }

        it 'returns less than 20 videos or equal' do
          assert data['videos'].size <= per_page
        end
      end

      describe 'with pagination page params 2' do
        let(:page) { 2 }
        let(:per_page) { 20 }

        it 'returns per_page count videos' do
          assert_equal data['videos'].size, 2
        end
      end
    end
  end

  describe 'GET /api/v5/videos/bookmarks' do
    subject { get 'api/v5/videos/bookmarks', params }

    let(:data) { Oj.load(last_response.body)['data'] }

    before { subject }
    describe 'without params' do
      let(:params) { { per_page: 20 } }

      it 'returns 200 status' do
        assert last_response.ok?
      end

      it 'has videos node' do
        assert data['videos']
      end
    end

    describe 'with pagination params' do
      let(:params) { { max_id: max_id, per_page: per_page } }

      describe 'with no pagination' do
        let(:max_id) { nil }
        let(:per_page) { 20 }

        it 'returns less than 20 videos or equal' do
          assert data['videos'].size <= per_page
        end
      end

      describe 'with pagination with max_id' do
        let(:max_id) { 2 }
        let(:per_page) { 20 }

        it 'returns less than 20 videos or equal' do
          assert_equal data['videos'].size, 1
        end
      end
    end
  end

  describe 'GET /api/v5/videos/:id' do
    subject { get "api/v5/videos/#{id}" }
    let(:data) { Oj.load(last_response.body)['data'] }
    let(:vcr_record_params) do
      {
        host: Settings.millvi[:host],
        id_vhost: Settings.millvi[:id_vhost],
        id_contents: '111',
        videotype: 'video',
        accesskey: 'v1,try-it,1455269885,3525ea5d3c284a865f5d32a8236a4eef65c081c0',
        useragent: ''
      }
    end
    before do
      Millvi.stub(:params, vcr_record_params) do
        VCR.use_cassette('millvi_get_video_url') do
          subject
        end
      end
    end
    describe 'with valid id' do
      let(:id) { Video.first.id }

      it 'returns status code 200' do
        assert last_response.ok?
      end

      it 'has some nodes' do
        assert data['is_bookmarked']
        assert data['duration']
        assert data['title']
        assert data['name']
        assert data['name_html']
        assert data['thumbnail_url']
        assert data['subname']
        assert data['chapters']
        assert data['video_url']
        assert data['current_student_watched_count']
        assert data['total_watched_count']
        assert data['is_bookmarked']
        assert data['next_videos']
        assert data['lessontext_url']
        assert data['lessontext_answer_url']
        assert data['lessontext_pdf_url']
        assert data['lessontext_answer_pdf_url']
        assert data['subject']
        assert data['double_speed_video_url']
      end
    end

    describe 'with invalid id' do
      let(:id) { Video.last.id + 1  }

      it 'returns status code 404' do
        assert_equal 404, last_response.status
      end
    end
  end
  describe 'GET /api/v5/videos/:year/:subject' do
    subject { get "/api/v5/videos/#{year}/#{subject_name}" }
    before { subject }
    let(:meta) { Oj.load(last_response.body)['meta'] }
    let(:data) { Oj.load(last_response.body)['data'] }

    [{ year: 'c1', subject_name: 'english_exam',    type: 'new' },
     { year: 'c1', subject_name: 'english_regular', type: 'learning' },
     { year: 'k',  subject_name: 'mathematics_2',   type: 'end' }]
    .each do |test_case|
      describe 'with valid params' do
        let(:year) { test_case[:year] }
        let(:subject_name) { test_case[:subject_name] }

        it 'returns 200' do
          assert_equal 200, meta['code']
        end

        it 'has data' do
          assert data['completed_trophies_count']
          assert data['total_trophies_count']
          assert data['completed_videos_count']
          assert data['total_videos_count']
          assert data['schoolbook_name']
          assert data['title']
          assert data['videos_suggest']
          assert data['units']
          assert data['schoolbook_name']
        end

        it "type subject is #{test_case[:type]}" do
          assert_equal test_case[:type], data['videos_suggest']['type']
        end
      end
    end

    describe 'with invalid params' do
      let(:year) { 'k' }
      let(:subject_name) { 'english_exam' }

      it 'returns status code 400' do
        assert_equal 400, meta['code']
      end
    end
  end

  describe 'GET /api/v5/videos/search' do
    subject { get 'api/v5/videos/search', params }

    let(:data) { Oj.load(last_response.body)['data'] }

    before { subject }

    %w(アルファベット 単語 アルフ 単).each do |key|
      describe 'without params grade' do
        let(:params) { { keyword: key } }

        it 'returns 200 status' do
          assert last_response.ok?
        end

        it 'has units_count node' do
          assert_equal data['units_count'], 1
        end

        it 'has videos_count node' do
          assert_equal data['videos_count'], 1
        end

        it 'has completed units node' do
          assert data['units'].first['completed']
        end
      end
    end
    describe 'with params combine multiple words' do
      let(:params) { { keyword: 'アルファベット 単語', grade: 'c' } }
      it 'returns 200 status' do
        assert last_response.ok?
      end

      it 'has units_count node' do
        assert_equal data['units_count'], 0
      end

      it 'has videos_count node' do
        assert_equal data['videos_count'], 0
      end
    end

    describe 'with params grade c' do
      let(:params) { { keyword: 'アルファベット', grade: 'c' } }
      it 'returns 200 status' do
        assert last_response.ok?
      end

      it 'has units_count node' do
        assert_equal data['units_count'], 1
      end

      it 'has videos_count node' do
        assert_equal data['videos_count'], 1
      end
    end

    describe 'with params grade k' do
      let(:params) { { keyword: 'アルファベット', grade: 'k' } }
      it 'returns 200 status' do
        assert last_response.ok?
      end

      it 'has units_count node' do
        assert_equal data['units_count'], 0
      end

      it 'has videos_count node' do
        assert_equal data['videos_count'], 0
      end
    end

    describe 'with pagination params' do
      describe 'with pagination page 1' do
        let(:params) { { keyword: 'be動詞の文', grade: 'c', page: 1, per_page: 20 } }
        it 'returns less than 20 videos or equal' do
          assert data['videos'].size <= 20
        end
      end

      describe 'with pagination page 2' do
        let(:params) { { keyword: 'be動詞の文', grade: 'c', page: 2, per_page: 1 } }
        it 'returns per_page count videos' do
          assert_equal data['videos'].size, 1
        end
      end
    end
  end

  describe 'POST /api/v5/videos/:id/plays' do
    subject { post "/api/v5/videos/#{video.id}/plays", { position: position_param } }

    describe 'position param is duration < position' do
      let(:position_param) { video.duration + 10 }
      let(:video) { Video.first }

      it 'return 201' do
        subject
        logger_nodes = @logger.messages_to_hash

        assert_equal last_response.status, 201
        assert_equal 'PlayVideo', logger_nodes['eventName']
        assert_equal video.duration, logger_nodes['eventData']['position']
      end
    end

    describe 'position param is position < duration' do
      let(:position_param) { video.duration - 10 }
      let(:video) { Video.first }

      it 'return 201' do
        subject
        logger_nodes = @logger.messages_to_hash

        assert_equal 201, last_response.status
        assert_equal 'PlayVideo', logger_nodes['eventName']
        assert_equal position_param, logger_nodes['eventData']['position']
      end
    end

    describe 'when position params is invalid' do
      describe 'with position < 0' do
        let(:position_param) { -2 }
        let(:video) { Video.first }

        it 'return 400' do
          subject
          logger_nodes = @logger.messages_to_hash

          assert_equal 400, last_response.status
          assert_equal 'InvalidPositionParams', logger_nodes['eventName']
          assert_equal 'Position params is smaller than 0',
                       logger_nodes['eventData']['error_message']
          assert_equal 400, JSON.parse(last_response.body)['meta']['code']
        end
      end
    end

    describe 'with position = 0' do
      let(:position_param) { 0 }
      let(:video) { Video.first }

      it 'return 201' do
        subject
        logger_nodes = @logger.messages_to_hash

        assert_equal 201, last_response.status
        assert_equal 'PlayVideo', logger_nodes['eventName']
        assert_equal position_param, logger_nodes['eventData']['position']
      end
    end
  end
end
