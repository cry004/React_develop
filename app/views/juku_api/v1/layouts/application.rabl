node(:meta) do
  unless @status_code
    hash = { code: options[:method] == ["GET"] ? 200 : 201 }
  else
    hash = { code: @status_code }
  end
  hash.merge!({ access_token: @current_chief.access_token }) if @current_chief.try(:access_token)
  hash
end

node(:data) do
  JSON.parse(yield)
end
