require 'test_helper'

class JukuAPI::V1::CurriculumTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include JukuAPI::Root.helpers

  def app
    Rails.application
  end

  def setup
    super
    @current_chief = Chief.take
    create_access_token
    update_access_token
    header 'Content-Type',    'application/json'
    header 'X-Authorization', "Bearer #{@access_token}"
  end

  let(:response_data) { Oj.load(last_response.body) }

  describe 'GET curriculum' do
    after { VCR.eject_cassette }

    subject { get "/juku/v1/students/#{student_id}/curriculums", params }

    let(:student_id) { Student.take.id }

    describe 'positive testing' do
      before { VCR.insert_cassette 'get_agreement_successfully' }

      let(:params) do
        { sub_subject_key: 'physics',
          agreement_id:    '1517',
          box_id:          '1',
          subject_id:      207 }
      end

      it 'should return 200' do
        subject
        assert_equal 200, last_response.status
      end

      it 'should return todo list' do
        subject
        todo_learning_ids = JSON.parse(last_response.body)['data']['learnings']['todo_learning_ids']
        learnings = JSON.parse(last_response.body)['data']['learnings']

        sub_units = learnings['units'].inject([]){|get_sub_units, unit| get_sub_units + unit['sub_units'].map{|m| m['sub_unit_id']}}
        max_index_sub_units_ids = learnings['learned_count']
        expect_todo_learning_ids = sub_units.from(max_index_sub_units_ids).take(3)

        assert_equal todo_learning_ids, expect_todo_learning_ids
      end
    end

    describe 'positive testing for subject sociology' do
      before { VCR.insert_cassette 'get_agreement_successfully' }

      let(:params) do
        { sub_subject_key: 'geography',
          agreement_id:    '1517',
          box_id:          '1',
          subject_id:      204 }
      end

      it 'should subjects be ordered' do
        subject
        sub_subjects         = JSON.parse(last_response.body)['data']['sub_subjects'].take(3)
        ordered_sub_subjects = sub_subjects.map{ |sub_sbj| sub_sbj['sub_subject_key'] }
        assert_equal ordered_sub_subjects, %w(geography history civics)
      end
    end
  end

  describe 'POST curriculum' do
    subject { post "/juku/v1/students/#{student_id}/curriculums", params }

    let(:student_id) { Student.take.id }
    let(:params) do
      Oj.dump(agreement_id:    '1517',
              agreement_dow:   '01',
              start_date:      '2016-06-01',
              end_date:        '2016-12-01',
              period_id:       '06',
              sub_unit_ids:    [1, 2, 3],
              sub_subject_key: 'c1_english_regular')
    end

    it 'should return 201' do
      subject
      assert_equal 201, last_response.status
    end

    it 'creates curriculum record' do
      assert_difference 'Curriculum.count', 1 do
        subject
      end
    end

    it 'creates learning records' do
      assert_difference 'Learning.count', 3 do
        subject
      end
    end

    it 'save counter columns' do
      subject
      curriculum = Curriculum.last
      assert_equal 3,  curriculum.total_count
      assert_equal 0,  curriculum.done_count
    end
  end

  describe 'PUT curriculum' do
    subject { put "/juku/v1/curriculums/#{curriculum.id}", params }

    let(:curriculum) { Curriculum.find(1) } # from fixtures
    let(:params) do
      Oj.dump(start_date:    '2017-01-01',
              end_date:      '2017-06-01',
              sub_unit_ids:  [7, 10])
    end

    it 'should return 200' do
      subject
      assert_equal 200, last_response.status
    end

    it 'releases learning records' do
      subject
      assert_equal [7, 10], curriculum.learnings.pluck(:sub_unit_id).sort
    end

    it 'save counter columns' do
      subject
      curriculum.reload
      assert_equal 2,  curriculum.total_count
      assert_equal 0,  curriculum.done_count
    end
  end

  describe 'GET number of weeks' do
    subject { get '/juku/v1/number_of_weeks', params }

    let(:params) { { start_date: '2016-6-1', end_date: '2016-12-1' } }

    it 'should return 200' do
      subject
      assert_equal 200, last_response.status
    end
  end
end
