require 'test_helper'

class API::V5::QuestionsTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include API::Root.helpers
  include ActionDispatch::TestProcess

  def app
    Rails.application
  end

  def setup_access_token
    create_access_token
    header 'X-Authorization', "Bearer #{@access_token}"
  end

  def setup
    super # Not done without SeedFu
    unless (name.include?('ログイン') || name.include?('login'))
      @current_student = Student.first
      setup_access_token
    end
  end

  def params
    @params ||= {}
  end

  def create_point_for_student
    @current_student.update(current_monthly_point: 15000)
  end

  def student_questions
    Question.unscope(where: :state).where(student: @current_student)
  end

  def id_can_be_unresolved
    student_questions.where(state: 'closed').first.id
  end

  def id_can_not_be_unresolved
    student_questions.where.not(state: 'closed').first.id
  end

  def id_can_be_resolved
    student_questions.where(state: 'answered_checked').first.id
  end

  def id_can_not_be_resolved
    student_questions.where.not(state: 'answered_checked').first.id
  end

  def question_draft_id
    student_questions.where(state: 'draft').first.id
  end

  def question_open_id
    student_questions.where(state: 'open').first.id
  end

  def question_initial_id
    student_questions.where(state: 'initial').where.not(video_id: nil).first.id
  end

  def question_with_video_initial_id
    create_point_for_student
    student_questions.where(state: 'initial').where.not(video_id: nil).first.id
  end

  def question_without_video_initial_id
    create_point_for_student
    student_questions.where(state: 'initial').where(video_id: nil).first.id
  end

  def not_exist_question_id
    student_questions.last.id + 1
  end

  def exist_unread_posts_id
    student_questions.find { |ques| ques.posts.unreads.exists? }.id
  end

  def not_exist_question_posts
    student = student_questions.first
    student.posts.destroy_all
    student.id
  end

  def question_id
    student_questions.first.id
  end

  def exist_video_id
    Video.first.id
  end

  def not_exist_video_id
    Video.last.id + 1
  end

  let(:meta) { Oj.load(last_response.body)['meta'] }
  let(:data) { Oj.load(last_response.body)['data'] }

  describe 'GET /api/v5/questions' do
    subject { get '/api/v5/questions', params }

    before { subject }

    describe 'without params' do
      let(:params) { {} }

      it 'returns 200 status' do
        assert last_response.ok?
      end

      it 'has questions node' do
        assert data['questions']
      end
    end

    describe 'with pagination params' do
      let(:params) { { page: page, per_page: per_page } }

      describe 'with no pagination' do
        let(:page)     { 1 }
        let(:per_page) { 20 }

        it 'returns less than 20 questions or equal' do
          assert data['questions'].size <= per_page
        end
      end

      describe 'with pagination' do
        let(:per_page) { student_questions.displayables.size - 1 }

        describe 'with page params 1' do
          let(:page) { 1 }
          it 'returns per_page count questions' do
            assert_equal data['questions'].size, per_page
          end
        end

        describe 'with page params 2' do
          let(:page) { 2 }
          it 'returns a question' do
            assert_equal data['questions'].size, 1
          end
        end
      end
    end
  end

  describe 'DELETE /api/v5/questions/:id' do
    subject { delete "/api/v5/questions/#{id}" }
    before { subject }

    describe 'with exist question' do
      let(:id) { question_id }
      let(:response) { Oj.load(last_response.body) }

      it 'returns status code 204' do
        assert_equal 204, last_response.status
      end

      it 'returns no body' do
        assert_nil response
      end
    end

    describe 'with not exist question' do
      let(:id) { not_exist_question_id }

      it 'returns status code 404' do
        assert_equal 404, last_response.status
      end
    end
  end

  describe 'POST /api/v5/questions' do
    subject { post '/api/v5/questions', params }
    before { subject }

    describe 'exist video' do
      let(:params) { { video_id: exist_video_id, position: 1 } }

      it 'returns status code 201' do
        assert_equal 201, meta['code']
      end

      it 'has data' do
        assert data['resource_url']
        assert data['question_id']
        assert data['date']
      end

      it 'creates a question with video' do
        assert exist_video_id, Question.unscoped.last.video_id
      end
    end

    describe 'not exist video' do
      let(:params) { { video_id: not_exist_video_id, position: 1 } }

      it 'returns status code 201' do
        assert_equal 201, meta['code']
      end

      it 'has data' do
        assert_nil data['resource_url']
        assert data['question_id']
        assert data['date']
      end

      it 'creates a question without video' do
        assert_nil Question.unscoped.last.video_id
      end
    end
  end

  describe 'GET /api/v5/questions/:id/drafts' do
    subject { get "/api/v5/questions/#{id}/drafts" }
    before { subject }

    describe 'exist draft' do
      let(:id) { question_draft_id }

      it 'returns status code 200' do
        assert_equal 200, meta['code']
      end

      it 'has data' do
        assert(data['id'])
      end
    end

    describe 'not exist draft' do
      let(:id) { not_exist_question_id }

      it 'returns status code 404' do
        assert_equal 404, meta['code']
      end
    end
  end

  describe 'PUT /api/v5/questions/:id/unresolves' do
    subject { put "/api/v5/questions/#{id}/unresolves" }
    before { subject }

    describe 'can be unresolve' do
      let(:id) { id_can_be_unresolved }
      it 'returns status code 200' do
        assert_equal 200, last_response.status
      end
    end

    describe 'can not be unresolved' do
      [{ title: 'state not closed', id: 'id_can_not_be_unresolved' },
       { title: 'id not found',     id: 'not_exist_question_id' }]
      .each do |test_case|
        describe test_case[:title] do
          let(:id) { send(test_case[:id]) }

          it 'returns status code 204' do
            assert_equal 204, meta['code']
          end
        end
      end
    end
  end

  describe 'GET /api/v5/questions/:id' do
    subject { get "api/v5/questions/#{id}" }
    before { subject }

    describe 'exist question' do
      let(:id) { question_id }

      it 'returns status code 200' do
        assert_equal 200, meta['code']
      end

      it 'has data' do
        assert data['id']
      end
    end

    describe 'not exist question' do
      let(:id) { not_exist_question_id }

      it 'returns status code 404' do
        assert_equal 404, meta['code']
      end
    end
  end

  describe 'PUT /api/v5/questions/:id/resolves' do
    subject { put "/api/v5/questions/#{id}/resolves" }
    before { subject }

    describe 'can be resolved' do
      let(:id) { id_can_be_resolved }
      it 'returns status code 200' do
        assert_equal 200, last_response.status
      end
    end

    describe 'can not be resolved' do
      [{ title: 'state not answered_checked', id: 'id_can_not_be_resolved' },
       { title: 'id not found',               id: 'not_exist_question_id' }]
      .each do |test_case|
        describe test_case[:title] do
          let(:id) { send(test_case[:id]) }

          it 'returns status code 204' do
            assert_equal 204, meta['code']
          end
        end
      end
    end
  end

  describe 'PUT /api/v5/questions/:id/reads' do
    subject { put "/api/v5/questions/#{id}/reads"}

    let(:meta) { Oj.load(last_response.body)['meta'] }

    describe 'exist unread_posts' do
      let(:id) { exist_unread_posts_id }

      it 'returns status code 200' do
        subject
        assert_equal 200, last_response.status
      end
    end

    describe 'not exist unread_posts' do
      test_cases = [
        { title: 'not exist question id', id: 'not_exist_question_id' },
        { title: 'not exist question posts', id: 'not_exist_question_posts' }
      ]

      test_cases.each do |test_case|
        describe test_case[:title] do
          let(:id) { send(test_case[:id]) }

          it 'returns status code 204' do
            subject
            assert_equal 204, meta['code']
          end
        end
      end
    end
  end

  describe 'PUT /api/v5/questions/:id' do
    subject { put "/api/v5/questions/#{id}", params }

    describe 'when not during the company holiday' do
      before do
        Timecop.freeze('28/12/2017')
        setup_access_token
        subject
      end
      after  { Timecop.return }

      [{ title: 'create question', create_flag: true },
       { title: 'draft question',  create_flag: false }]
      .each do |test_case|
        describe "#{test_case[:title]}" do
          describe 'with with_video params' do
            let(:params) { { create_flag: test_case[:create_flag], with_video: { body: 'body' } } }
            let(:id) { question_with_video_initial_id }

            it 'returns status code 201' do
              assert_equal 201, meta['code']
            end

            it 'has data necessary' do
              assert data['id']
              assert data['state']
              assert data['type']
              assert data['posts']
            end
          end

          describe 'with without_video params' do
            let(:params) do
              { create_flag: test_case[:create_flag],
                without_video: { body: 'body',
                                 course_name: 'english',
                                 upload_file: fixture_file_upload('files/login_mrtry.png', 'image/png') } }
            end
            let(:id) { question_without_video_initial_id }

            it 'returns status code 201' do
              assert_equal 201, meta['code']
            end

            it 'has data necessary' do
              assert data['id']
              assert data['state']
              assert data['type']
              assert data['posts']
            end
          end
        end
      end

      describe 'update question if question is opened' do
        let(:params) { { create_flag: false } }
        let(:id)     { question_open_id }

        it 'returns status code 204' do
          assert_equal 204, meta['code']
        end
      end

      describe 'create question if question id is not existed' do
        let(:params) { { create_flag: false } }
        let(:id)     { not_exist_question_id }

        it 'returns status code 404' do
          assert_equal 404, meta['code']
        end
      end

      describe 'create question if current point is shortage' do
        let(:params) { { create_flag: true, with_video: { body: 'body' } } }
        let(:id)     { question_initial_id }

        it 'returns status code 404' do
          assert_equal 404, meta['code']
        end
      end

      describe 'create question if question is initialed with_video or without_video' do
        let(:params) { { create_flag: true } }
        let(:id)     { question_initial_id }

        it 'returns status code 400' do
          assert_equal 400, meta['code']
        end
      end

      describe 'create question if question is initialed with video and empty values in with_video' do
        let(:params) { { create_flag: true, with_video: {} } }
        let(:id)     { question_with_video_initial_id }

        it 'returns status code 400' do
          assert_equal 400, meta['code']
        end
      end

      describe 'create question if question is initialed without video and empty values in without_video' do
        let(:params) { { create_flag: true, without_video: {} } }
        let(:id)     { question_without_video_initial_id }

        it 'returns status code 400' do
          assert_equal 400, meta['code']
        end
      end
    end

    describe 'when during the company holiday' do
      before do
        Timecop.freeze('29/12/2017')
        setup_access_token
        subject
      end
      after  { Timecop.return }
      describe "create question with 'with_video' params" do
        let(:params) { { create_flag: true, with_video: { body: 'body' } } }
        let(:id) { question_with_video_initial_id }

        it 'returns 400 status code' do
          subject
          assert_equal 400, meta['code']
        end
      end

      describe 'draft questions' do
        describe 'with with_video params' do
          let(:params) { { create_flag: false, with_video: { body: 'body' } } }
          let(:id) { question_with_video_initial_id }

          it 'returns status code 201' do
            assert_equal 201, meta['code']
          end

          it 'has data necessary' do
            assert data['id']
            assert data['state']
            assert data['type']
            assert data['posts']
          end
        end

        describe 'with without_video params' do
          let(:id) { question_without_video_initial_id }
          let(:params) do
            { create_flag: false,
              without_video: { body: 'body',
                               course_name: 'english',
                               upload_file: fixture_file_upload('files/login_mrtry.png', 'image/png') } }
          end

          it 'returns status code 201' do
            assert_equal 201, meta['code']
          end

          it 'has data necessary' do
            assert data['id']
            assert data['state']
            assert data['type']
            assert data['posts']
          end
        end
      end
    end
  end

  describe 'GET /api/v5/questions/createability' do
    subject { get '/api/v5/questions/createability' }

    describe 'when during the company holiday' do
      before do
        Timecop.freeze('03/01/2018')
        setup_access_token
      end
      after  { Timecop.return }

      it 'returns 400 status code' do
        subject
        assert_equal 400, meta['code']
      end
    end

    describe 'when not during the company holiday' do
      before do
        Timecop.freeze('04/01/2018')
        setup_access_token
      end
      after  { Timecop.return }

      it 'returns status code 200' do
        subject
        assert_equal 200, meta['code']
      end
    end
  end
end
