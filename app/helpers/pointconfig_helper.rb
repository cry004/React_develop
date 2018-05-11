module PointconfigHelper
  def this_month_of(student)
    if student.current_monthly_point == 0
      '未設定'
    else
      "#{number_to_currency(student.current_monthly_point, unit: '', precision: 0)}円"
    end
  end

  def next_month_of(student)
    if student.following_monthly_point == 0
      '未設定'
    else
      "#{number_to_currency(student.following_monthly_point, unit: '', precision: 0)}円"
    end
  end

  def confirm_next_month_of(student)
    if student.following_monthly_point == 0
      '未設定'
    else
      "#{number_to_currency(student.following_monthly_point, unit: '', precision: 0)}円(税別)/月まで"
    end
  end
end
