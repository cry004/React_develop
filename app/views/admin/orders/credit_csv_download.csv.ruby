require 'csv'
require 'nkf'
csv_str = CSV.generate do |csv|
  csv << ["質問ID", "質問の状態", "質問の作成日", "生徒ID", "生徒ログインID", "保護者ID","顧客ID","保護者メールアドレス", "注文ID","注文者ID"," 注文作成日", "注文の状態","料金(税込み)","与信の種類","決済ステータス","決済日"]
  @csv_data.lazy.each do |data|
    question_id, question_state,question_created_at,student_id, student_username, parent_id, customer_id,parent_email,order_id,orderable_id,order_created_at, order_state,price,credit_type = Array.new(14,"")
    case data
    when Question
      student = data.student
      next if student.current_member_type == "tester"
      parent = student.parent
      order = data.order
      question_id = data.id
      question_state = data.human_state_name
      question_created_at = data.accepted_or_refused_at
      student_id = student.id
      student_username = student.username
      parent_id = parent.id
      customer_id = order.customer_id
      parent_email = parent.email
      order_id = order.id
      orderable_id = student.id
      order_created_at = order.created_at
      order_state = order.human_state_name
      price = (order.total_point * Settings.tax_rate).to_i
      credit_type = "ポイント上限与信"
    when Order
      if data.orderable_type == "Student"
        student = data.student
        student_id = student.id
        student_username = student.username
        credit_type = "ポイント上限与信"
      else
        # studentのcurrent_member_typeがtesterであるかどうかをチェックするためだけに使用する。
        # 保護者からtesterであるかどうかはわからず、かつtesterのstudentsは一人なので、students.firstとしている。
        student = data.orderable.students.first
        credit_type = "問題集購入与信"
      end
      next if student.current_member_type == "tester"
      parent = data.parent
      parent_id = parent.id
      parent_email = parent.email
      customer_id = data.customer_id
      order_id = data.id
      orderable_id = data.orderable.id
      order_created_at = data.created_at
      order_state = data.human_state_name
      price = (data.total_point * Settings.tax_rate).to_i
    end
    csv << [question_id, question_state,question_created_at,student_id, student_username, parent_id, customer_id,parent_email,order_id,orderable_id,order_created_at,order_state,price,credit_type
    ]
  end
end
# 出力をCP932でエンコーディング, 改行としてCRLFを出力する。
NKF::nkf('--oc=CP932 -Lw', csv_str)