require 'csv'
require 'nkf'
csv_str = CSV.generate do |csv|
  csv <<
  ["", "", "店舗","生徒ＮＯ", "生徒ユーザーID","生徒名","フリガナ", "学年", "郵便番号", "住所", "", "", "宛名", "TEL",
  "映像授業用問題集\n（確認テスト）\n【通常学習　英語　１年】",
  "映像授業用問題集\n（確認テスト）\n【通常学習　英語　２年】",
  "映像授業用問題集\n（確認テスト）\n【通常学習　英語　３年】",
  "映像授業用問題集\n（チェックテスト）\n【通常学習　英語　教科書未設定】",
  "映像授業用問題集\n（チェックテスト）\n【テスト対策　英語　NEW HORIZON】",
  "映像授業用問題集\n（チェックテスト）\n【テスト対策　英語　Sunshine】",
  "映像授業用問題集\n（チェックテスト）\n【テスト対策　英語　TOTAL ENGLISH】",
  "映像授業用問題集\n（チェックテスト）\n【テスト対策　英語　NEW CROWN】",
  "映像授業用問題集\n（チェックテスト）\n【テスト対策　英語　ONE WORLD】",
  "映像授業用問題集\n（チェックテスト）\n【テスト対策　英語　COLUMBUS21】",
  "映像授業用問題集\n（確認テスト）\n【通常学習　数学　１年】",
  "映像授業用問題集\n（確認テスト）\n【通常学習　数学　２年】",
  "映像授業用問題集\n（確認テスト）\n【通常学習　数学　３年】",
  "映像授業用問題集\n（チェックテスト）\n【テスト対策　数学】",
  "映像授業用問題集\n（確認テスト）\n【通常学習　理科　１年】",
  "映像授業用問題集\n（確認テスト）\n【通常学習　理科　２年】",
  "映像授業用問題集\n（確認テスト）\n【通常学習　理科　３年】",
  "映像授業用問題集\n（チェックテスト）\n【テスト対策　理科】",
  "映像授業用問題集\n（確認テスト）\n【通常学習　地理】",
  "映像授業用問題集\n（確認テスト）\n【通常学習　歴史】",
  "映像授業用問題集\n（確認テスト）\n【通常学習　公民】",
  "映像授業用問題集\n（チェックテスト）\n【テスト対策　社会】",
  "映像授業用問題集\n英語文法\n授業テキスト(高校)",
  "映像授業用問題集\n数学Ⅰ\n授業テキスト(高校)",
  "映像授業用問題集\n数学A\n授業テキスト(高校)",
  "映像授業用問題集\n数学Ⅱ\n授業テキスト(高校)",
  "映像授業用問題集\n数学B\n授業テキスト(高校)"]
  @csv_data.all.each do |data|
    student = data.student
    parent = data.parent
    address = if parent.domestic?
                "#{JpPrefecture::Prefecture.find(parent.prefecture_code).try(:name)}#{parent.city}"
              else
                parent.foreign_address
              end
    address1 = parent.address1
    address2 = parent.address2
    csv <<
    [nil,nil,nil,student.sit_cd, student.username, student.full_name, student.full_name_kana, GknnCd::Map[student.gknn_cd.to_s], parent.zip, address, address1, address2, parent.full_name, parent.tel, *data.data_for_csv
    ]
  end
end
# 出力をCP932でエンコーディング, 改行としてCRLFを出力する。
NKF::nkf('--oc=CP932 -Lw', csv_str)