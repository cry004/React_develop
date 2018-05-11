require 'csv'
require 'nkf'
csv_str = CSV.generate do |csv|
  csv << ["video_filename", "sit_cd", "student_name", "position","notebook_url", "created_at"]
  @csv_data.all.each do |data|
    csv << [data.video_filename, data.student_sit_cd, data.student_name, data.position, data.notebook_url, data.created_at]
  end
end
# 出力をCP932でエンコーディング, 改行としてCRLFを出力する。
NKF::nkf('--oc=CP932 -Lw', csv_str)