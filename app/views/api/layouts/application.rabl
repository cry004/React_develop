node(:meta) do
  unless @status_code
    hash = { code: options[:method] == ["GET"] ? 200 : 201 }
  else
    hash = { code: @status_code }
  end
  hash.merge!({ access_token: @current_student.access_token }) if @current_student.try(:access_token)
  hash.merge!({ player_type: @player_type }) # FIXME: Remove this when V3 is removed
  hash
end

node(:data) { Oj.load(yield) }
