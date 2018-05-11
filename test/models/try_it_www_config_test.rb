require "test_helper"

class TryItWwwConfigTest < ActiveSupport::TestCase
  def try_it_www_config
    @try_it_www_config ||= TryItWwwConfig.instance
  end

  def test_valid
    assert try_it_www_config.valid?
  end
end
