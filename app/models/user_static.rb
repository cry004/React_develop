# == Schema Information
#
# Table name: user_statics
#
#  id                                              :integer          not null, primary key
#  fist_parent_count                               :integer          default(0)
#  fist_student_count                              :integer          default(0)
#  fist_settings_creditcard_parent_count           :integer          default(0)
#  tryit_parent_count                              :integer          default(0)
#  tryit_student_count                             :integer          default(0)
#  tryit_settings_creditcard_parent_count          :integer          default(0)
#  created_at                                      :datetime         not null
#  updated_at                                      :datetime         not null
#  holidays                                        :json
#  schollbooks_settings_state_true_students_count  :integer          default(0), not null
#  schollbooks_settings_state_false_students_count :integer          default(0), not null
#


class UserStatic < ActiveRecord::Base
  acts_as_singleton

  def holiday?(date)
    yearmonth = date.strftime("%Y%m")
    day = date.day.to_s

    self.holidays.to_a.any? do |item|
      item['month'] == yearmonth && item['holidays'].include?(day)
    end
  end
end
