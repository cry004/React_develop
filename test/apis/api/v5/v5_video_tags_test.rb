require 'test_helper'

class API::V5::VideoTagsTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include API::Root.helpers

  def app
    Rails.application
  end

  def setup
    super # Not done without SeedFu
    unless (name.include?('ログイン') || name.include?('login'))
      @current_student = Student.second
      create_access_token
      header 'X-Authorization', "Bearer #{@access_token}"
    end
  end

  def params
    @params ||= {}
  end

  def tag_values(video_tag_name)
    video_tag = tags.select{ |tag| tag['name'] == video_tag_name }
    video_tag_values = video_tag.map{ |tag| tag['values'] }.flatten
  end

  describe 'GET /api/v5/video_tags' do
    subject { get '/api/v5/video_tags' }
    before { subject }

    let(:tags) { Oj.load(last_response.body)['data']['tags'] }

    it 'returns status 200' do
      assert_equal 200, last_response.status
    end

    it 'returns tags with name and values' do
      assert tags.all? { |tag| tag['name'] }
      assert tags.all? { |tag| tag['values'] }
    end

    it 'returns unique value' do
      assert_equal tag_values('duplicate'), tag_values('duplicate').uniq
    end
  end
end
