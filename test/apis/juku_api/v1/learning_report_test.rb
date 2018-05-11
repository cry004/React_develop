require 'test_helper'

class JukuAPI::V1::LearningReportTest < ActiveSupport::TestCase
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

  describe 'GET learning report' do
    after { VCR.eject_cassette }

    subject { get "/juku/v1/boxes/#{box_id}/learning_reports", params }

    let(:box_id) { 6 }
    let(:params) do
      { subject_id:   207,
        agreement_id: 1517,
        reported_at:  '2016-07-01 19:10:00' }
    end

    describe 'positive testing' do
      before { VCR.insert_cassette 'get_agreement_successfully' }

      it 'should return 200' do
        subject
        assert_equal 200, last_response.status
      end
    end
  end

  describe 'POST learning report' do
    subject { post '/juku/v1/learning_reports', params }

    let(:params) do
      Oj.dump(box_id:      2,
              reported_at: '2016-6-1 19:2:32',
              agreement_id: '012345678901-123',
              student_id: 1,
              )
    end

    let(:to_pass)                         { ::Learning.find(2) } # from fixtures
    let(:different_box_id_learnings)      { ::Learning.find(9) } # from fixtures
    let(:different_student_id_learnings)  { ::Learning.find(12) } # from fixtures

    it 'should return 201' do
      subject
      assert_equal 201, last_response.status
    end

    it 'changes statuses' do
      subject
      assert to_pass.reload.pass?
    end

    it 'should not changes different box_id learnings' do
      subject
      assert different_box_id_learnings.reload.sent?
    end

    it 'should not changes different box_id learnings' do
      subject
      assert different_student_id_learnings.reload.sent?
    end

  end
end
