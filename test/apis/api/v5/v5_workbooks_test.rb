require 'test_helper'
class API::V5::WorkbooksTest < ActiveSupport::TestCase
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

  # Not done without DBClean
  def teardown
    super
  end

  def cookies
    @cookies ||= {}
  end

  def params
    @params ||= {}
  end

  describe 'GET /api/v5/workbooks' do
    subject { get '/api/v5/workbooks' }
    before { subject }

    let(:data) { Oj.load(last_response.body)['data'] }

    it 'returns response ok' do
      assert last_response.ok?
    end

    it 'returns valid response data' do
      subjects = data['subjects']
      subjects_block = lambda do |node|
        valid_keys = %w(school_name subject_name workbooks)
        Set.new(valid_keys) == Set.new(node.keys)
      end

      workbooks = subjects.map { |subject| subject['workbooks'] }
      workbooks_block = lambda do |node|
        valid_keys = %w(id name name_short name_html schoolyear url image)
        Set.new(valid_keys) == Set.new(node.flat_map(&:keys).uniq)
      end

      assert subjects.all?(&subjects_block)
      assert workbooks.all?(&workbooks_block)
    end
  end
end
