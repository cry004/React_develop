# == Schema Information
#
# Table name: chiefs
#
#  id             :integer          not null, primary key
#  access_token   :string
#  one_time_token :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  shin_cd        :string
#  classroom_id   :integer
#
# Indexes
#
#  index_chiefs_on_access_token  (access_token)
#  index_chiefs_on_classroom_id  (classroom_id)
#  index_chiefs_on_shin_cd       (shin_cd) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (classroom_id => classrooms.id)
#

require "test_helper"

class ChiefTest < ActiveSupport::TestCase
  describe '#validations' do
    %i(shin_cd classroom_id).each do |column|
      describe 'with presence' do
        subject { Chief.new }

        it 'rejects a bad #{column} in validation' do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.blank')
        end
      end
    end
  end
end
