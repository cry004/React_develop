require 'test_helper'

class API::V5::UnitsTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include API::Root.helpers

  def app
    Rails.application
  end

  def setup
    super # Not done without SeedFu
    unless name.include?('ログイン') || name.include?('login')
      @current_student = Student.second
      create_access_token
      header 'X-Authorization', "Bearer #{@access_token}"
    end
  end

  def params
    @params ||= {}
  end

  describe 'GET /api/v5/units/videos' do
    subject { get '/api/v5/units/videos', params }
    before { subject }

    let(:sub_unit) { Oj.load(last_response.body)['data'] }
    let(:params) { { title: 'Let\'s Enjoy English!', title_description: '', schoolbook_id: 19 } }

    it 'returns status 200' do
      assert_equal 200, last_response.status
    end

    it 'returns sub_unit list' do
      assert_equal sub_unit.size, 3
    end

    it 'returns sub_unit with title and video_id and video_watched_flag' do
      assert sub_unit.all? { |sub_unit| sub_unit['title'] }
      assert sub_unit.all? { |sub_unit| sub_unit['video_id'] }
      assert sub_unit.all? { |sub_unit| sub_unit['video_watched_flag'] == true}
    end
  end
end
