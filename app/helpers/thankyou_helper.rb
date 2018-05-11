module ThankyouHelper
  def mail_to_parent_subject
    '【保護者様よりご連絡】永久０円で中学・高校の映像授業が見放題（家庭教師のトライ）'
  end

  def mail_to_parent_body(parent)
    return '' if parent.blank?
    body = <<"EOS"
保護者様が、映像学習サービスTry IT（トライイット）の会員登録を完了しました。

下記URLをクリックして、今すぐ映像授業をご活用ください。
https://www.try-it.jp/download/

なお、映像授業を見るには、保護者様が登録したIDとパスワードが必要です。

————————————————
▼生徒（利用者）のID
————————————————
#{student_list(parent)}

パスワードは個人情報保護の観点から本メールでは表示しません。
保護者様に直接聞いていただきますようお願いいたします。

家庭教師のトライ
EOS
    return body
  end

  def line_to_parent_body(parent)
    return '' if parent.blank?
    body = <<"EOS"
学校の授業より断然わかりやすい映像授業が見放題（中学・高校）
今すぐ試してみて！
————————————————
▼生徒（利用者）のID
————————————————
#{student_list(parent)}

（パスワードは聞いてね）

https://www.try-it.jp/download/
EOS
    return "line://msg/text/#{URI.escape(body)}"
  end

  def student_list(parent)
    parent.students.map{|s| s.full_name + 'のID : ' + s.username}.join("\n")
  end
end
