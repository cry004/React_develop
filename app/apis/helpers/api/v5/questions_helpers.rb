module API::V5::QuestionsHelpers
  include EventLogHelper
  COMPANY_HOLIDAYS_START_DATE = (ENV['COMPANY_HOLIDAYS_START_DATE'] || Settings.company_holidays.start_date).to_date
  COMPANY_HOLIDAYS_END_DATE   = (ENV['COMPANY_HOLIDAYS_END_DATE']   || Settings.company_holidays.end_date).to_date

  def params_for_log(params)
    params.delete_if { |key, _value| key.in?(%(page per_page)) }
  end

  def company_holiday?(date = Time.zone.today)
    date.between?(COMPANY_HOLIDAYS_START_DATE, COMPANY_HOLIDAYS_END_DATE)
  end

  def day_of_week(date)
    date.to_datetime.to_s(:day_of_week_jp_standard)
  end

  def time_of_holidays(start_date, end_date)
    { start_date: day_of_week(start_date), end_date: day_of_week(end_date) }
  end

  def message_about(message_name)
    message = I18n.t("errors.messages.#{message_name}",
                     time_of_holidays(COMPANY_HOLIDAYS_START_DATE, COMPANY_HOLIDAYS_END_DATE))
    error 'CanNotCreateQuestion', message, 400, true, 'error'
  end
end
