require 'rails/test_help'

ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'minitest/rails'

require 'minitest/reporters'
require 'minitest/stub_any_instance'
require 'json_expressions/minitest'
require 'database_cleaner'

class ActiveSupport::TestCase
  # Checks for pending migration and applies them before tests are run.
  # If you are not using ActiveRecord, you can remove this line.
  ActiveRecord::Migration.maintain_test_schema!

  Minitest::Reporters.use!

  DatabaseCleaner.clean_with :truncation

  SeedFu.quiet = true
  SeedFu.seed('db/fixtures/test')

  DatabaseCleaner.strategy = :transaction

  before do
    DatabaseCleaner.start
  end

  after do
    DatabaseCleaner.clean
  end

  # Add more helper methods to be used by all tests here...
end

# for VCR
VCR.configure do |config|
  config.cassette_library_dir = 'test/cassettes'
  config.hook_into :webmock
  config.default_cassette_options = {
    match_requests_on: %i(method uri body)
  }
end

# for Faraday
module SilentFaraday
  def initialize(app, logger = nil, options = {})
    super
    @logger.level = ::Logger::WARN
  end
end

class Faraday::Response::Logger
  prepend SilentFaraday
end

# ログの出力をcaptureするためのクラス
class TestLogger < Logger
  def initialize
    @strio = StringIO.new
    super(@strio)
  end

  def messages_to_hash
    @strio.string
    JSON.parse(@strio.string.match(/{.+}/).to_s)
  end
end

# ログの出力をmessageのみに絞るためのクラス.
# このインスタンスをformatterに指定するとcallが呼び出されて
# callの戻り値がログ出力となる.
class SimpleLogFommater
  def call(severity, timestamp, progname, msg)
    msg
  end
end
