node(:meta) do
  unless @status_code
    hash = { code: options[:method] == ["GET"] ? 200 : 201 }
  else
    hash = { code: @status_code }
  end
  hash
end

node(:data) do
  JSON.parse(yield)
end