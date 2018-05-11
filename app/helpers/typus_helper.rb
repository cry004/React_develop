module TypusHelper
  def custom_fields
    case params[:action]
    when "history_for_examined"
      fields.to_hash.reject! {|k, v| k == "answerer_email" }
    else
      if admin_user.role == "admin" || admin_user.role == "executive_answerer"
        fields.to_hash
      else
        fields.to_hash.reject! {|k, v| k == "gatekeeper_email" || k == "answerer_email" || k == "accepted_or_refused_at"}
      end
    end
  end

  def render_table
    if params[:action] == "history_for_answered" || params[:action] == "histroy_for_answered_checked"
      render partial: "admin/questions/tables/history_for_answered", locals: { items: @items }
    else
      render "admin/questions/tables/index", { model: @resource, fields: custom_fields, items: @items, headers: table_header(@resource, custom_fields)}
    end
  end

  # 一覧する質問の種類に応じてstateの表示を変更する。
  def decorate_state(item)
    case params[:action]
    when "history_for_examined"
      exmined_state(item.state)
    when "history_for_answered"
      answered_state(item.state)
    when "histroy_for_answered_checked"
      answered_state(item.state)
    else
      item.human_state_name
    end
  end

  # 回答履歴用のヘルパー
  # [質問ID, 生徒ID, 生徒の学年, 科目, 動画, タイトル, 状態, 作成日]
  def table_fields_for_history_for_answered(item)
    question = item.question
    [
      question.id,
      question.student.sit_cd,
      question.student_schoolyear,
      question.school_type_name,
      question.subject_name,
      question.has_video?,
      question.video_subject_name,
      question.title,
      question.state,
      item.postable.try(:email),
      question.created_at
    ]
  end

  def table_fields_for_line_items(line_item)
    [
      line_item.product_name,
      line_item.point,
      line_item.quantity,
      line_item.product_category,
      line_item.product_subject_name,
      line_item.product_subject_type,
      line_item.product_school,
      line_item.product_year,
      line_item.schoolbook_name
    ]
  end

  def return_link(question)
    case question.state
    when "examining"
      ["検閲の続きを行う", { controller: "admin/questions", action: :examine, id: question.id }, { class: "typus__button__ok" }]
    when "assigned"
      ["回答の続きを行う", { controller: "admin/questions", action: :assign, id: question.id }, { class: "typus__button__ok" }]
    when "checking"
      ["承認の続きを行う", { controller: "admin/questions", action: :work, id: question.id }, { class: "typus__button__ok" }]
    end
  end

  def stop_link(question)
    case question.state
    when "examining"
      ["検閲をやめる", { controller: "admin/questions", action: :stop_examine, id: question.id }, { class: "typus__button__cancel" }]
    when "assigned"
      ["回答をやめる", { controller: "admin/questions", action: :deassign, id: question.id }, { class: "typus__button__cancel" }]
    when "checking"
      ["承認をやめる", { controller: "admin/questions", action: :stop_work, id: question.id }, { class: "typus__button__cancel" }]
    end
  end

  # 検閲履歴の状態を表示する(検閲済みもしくは、差し戻し)
  def exmined_state(state)
    case state
    when "open"
      "未検閲"
    when "refused"
      "差し戻し"
    when "examining"
      "検閲中"
    when "pending"
      "保留中"
    else
      "検閲済み"
    end
  end

  # 回答履歴の状態を表示する(未承認、承認済み、不採用)
  def answered_state(state)
    case state
    when "draft"
      "未承認"
    when "accepted_unread", "accepted_read"
      "承認済"
    when "question_refused"
      "質問差し戻し"
    when "rejected"
      "不採用"
    end
  end

  # 管理者ユーザのフォームに必要なをフィールドを返す
  def custom_fields_for_admin_user
    {
      "last_name" => :string,
      "first_name" => :string,
      "last_name_kana" => :string,
      "first_name_kana" => :string,
      "role" => :selector,
      "email" => :string,
      "tel" => :string,
      "password" => :password,
      "password_confirmation" => :password,
      "locale" => :selector,
      "status" => :boolean
    }
  end

  def custom_fields_for_edit_admin_user
    {
      "last_name" => :string,
      "first_name" => :string,
      "last_name_kana" => :string,
      "first_name_kana" => :string,
      "password" => :password,
      "password_confirmation" => :password,
      "status" => :boolean
    }
  end

  def custom_fields_for_edit_password
    {
      "password" => :password,
      "password_confirmation" => :password
    }
  end
end
