json.eventVersion    Settings.event_version

json.userIdentity    do
  json.principalId user.try!(:id)
  json.kys_cd      user.try!(:kys_cd) if user.class.to_s == "AdminUser"
  json.type        user.class.to_s

  json.additionalData do
    case user
    when AdminUser
      json.role                 user.role
      json.rank                 user.rank
    end
  end
end

json.eventTime       Time.now.iso8601
json.eventSource     request.host
json.eventName       event_name
json.eventData       event_data
json.sourceIPAddress request.env[:HTTP_X_FORWARDED_FOR] || request.env[:REMOTE_ADDR]
json.userAgent       request.user_agent
json.eventId         SecureRandom.uuid