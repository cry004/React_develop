module BillingHelper
  def options_for_billing_yyyymm(end_date, start_date)
    number_of_months = (end_date.year * 12 + end_date.month) - (start_date.year * 12 + start_date.month) + 1
    number_of_months.times.each_with_object([]) do |count, array|
      array << [(end_date - count.months).strftime('%Y年%m月'), (end_date - count.months).strftime('%Y%m')]
    end
  end
end
