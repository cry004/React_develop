object false
node(:principalId)   { @user.present? ? @user.id : nil }
node("co-accountId") { @user.present? ? @user.username : nil }
node(:type)          { @user.present? ? @user.class : nil }
node(:additionalData) do
  case @user
  when Student
    { gknn_cd:              @user.gknn_cd,
      school:               @user.school,
      sex:                  @user.sex,
      prefecture_code:      @user.parent.try(:prefecture_code),
      original_member_type: @user.original_member_type,
      current_member_type:  @user.current_member_type }
  else
    nil
  end
end
