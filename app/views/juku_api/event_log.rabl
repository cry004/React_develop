object false

node(:eventVersion)    { Settings.event_version }
node(:userIdentity)    { partial('_user_identity', object: false, locals: { user: @user }) }
node(:eventTime)       { Time.now.iso8601 }
node(:eventSource)     { @request.host }
node(:eventName)       { @event_name }
node(:eventData)       { @event_data }
node(:sourceIPAddress) { @request.env['HTTP_X_FORWARDED_FOR'] || @request.env['REMOTE_ADDR'] }
node(:userAgent)       { @request.user_agent }
node(:eventId)         { SecureRandom.uuid }
