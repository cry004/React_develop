require 'test_helper'

class StudentAvatarTest < ActiveSupport::TestCase
  def student_avatar
    @student_avatar ||= StudentAvatar.new
  end

  def test_valid
    assert student_avatar.valid?
  end
end
