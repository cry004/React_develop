require 'csv'
require 'nkf'
csv_str = CSV.generate do |csv|
  csv << ["id", "first_name", "last_name", "email", "tel", "role", "status", "rank", "accepted_posts_at_prev_month"]
  @csv_data.find_each do |data|
    data.exec_decide_answerer_rank
    csv << [data.id, data.first_name, data.last_name, data.email, data.tel, data.role, data.status, data.rank, data.accepted_posts_at_prev_month.count]
  end
end
# 出力をCP932でエンコーディング, 改行としてCRLFを出力する。
NKF::nkf('--oc=CP932 -Lw', csv_str)