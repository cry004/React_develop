require 'test_helper'

class JukuAPI::V1::LearningTest < ActiveSupport::TestCase
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

  describe 'GET learnings' do
    subject { get "/juku/v1/students/#{student_id}/learnings", params }

    let(:student_id) { Student.take.id }
    let(:params) { { box_id: 1 } }

    it 'should return 200' do
      subject
      assert_equal 200, last_response.status
    end
  end

  describe 'GET learning histories' do
    subject { get "/juku/v1/students/#{student_id}/learnings/histories" }

    let(:student_id) { Student.take.id }

    it 'should return 200' do
      subject
      assert_equal 200, last_response.status
    end
  end

  describe 'PUT learning' do
    subject { put '/juku/v1/learnings', params }

    describe 'when scheduled' do
      let(:params) do
        Oj.dump(learning_id: learning_id, status:  'scheduled',
                box_id:      nil,         sent_on: nil)
      end

      let(:learning_id) { learning.id }

      describe 'without curriculum' do
        let(:learning) do
          ::Learning.find_by(status: :sent, curriculum_id: nil)
        end

        it 'should return 200' do
          subject
          assert_equal 200, last_response.status
        end

        it 'returns status' do
          subject
          assert_equal 'scheduled', response_data['data']['learning_status']
        end
      end

      describe 'with curriculum' do
        let(:learning) do
          ::Learning.where.not(curriculum_id: nil).find_by(status: :sent)
        end

        it 'should return 200' do
          subject
          assert_equal 200, last_response.status
        end

        it 'returns status' do
          subject
          assert_equal 'scheduled', response_data['data']['learning_status']
        end
      end
    end

    describe 'when sent' do
      let(:params) do
        Oj.dump(learning_id: learning_id, status:  'sent',
                box_id:      1,           sent_on: '2016-1-1')
      end

      let(:learning)    { ::Learning.find_by(status: :scheduled) }
      let(:learning_id) { learning.id }

      it 'should return 200' do
        subject
        assert_equal 200, last_response.status
      end

      it 'changes status' do
        subject
        assert learning.reload.sent?
      end

      it 'returns status' do
        subject
        assert_equal 'sent', response_data['data']['learning_status']
      end
    end

    describe 'when resent' do
      let(:params) do
        Oj.dump(learning_id: learning_id, status:  'resent',
                box_id:      1,           sent_on: '2016-1-1')
      end

      let(:learning)    { ::Learning.find_by(status: :pass) }
      let(:learning_id) { learning.id }

      it 'should return 200' do
        subject
        assert_equal 200, last_response.status
      end

      it 'creates learning record' do
        assert_difference 'Learning.count', 1 do
          subject
        end
      end

      it 'returns status' do
        subject
        assert_equal 'sent', response_data['data']['learning_status']
      end
    end

    describe 'when sent without learning_id' do
      let(:params) do
        Oj.dump(sub_unit_id:  sub_unit_id, status:  'sent',
                box_id:       1,           sent_on: '2016-1-1',
                student_id:   1,           period_id: '06',
                agreement_id: '123')
      end

      let(:sub_unit_id) { SubUnit.take.id }

      it 'should return 200' do
        subject
        assert_equal 200, last_response.status
      end

      it 'returns status' do
        subject
        assert_equal 'sent', response_data['data']['learning_status']
      end
    end
  end
end
