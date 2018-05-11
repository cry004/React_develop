require "test_helper"

class CarouselTest < ActiveSupport::TestCase
  def carousel
    @carousel ||= Carousel.new
  end

  def test_valid
    assert carousel.valid?
  end
end
