require 'test_helper'

class JukuAPI::V1::RootTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rails.application
  end

  let(:response_data) { Oj.load(last_response.body) }
end
