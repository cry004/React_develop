class Admin::QuestionsController < Admin::ResourcesController
  include ::TypusHelper

  def index
    if @admin_user.role == "answerer"
      redirect_to controller: "admin/questions", action: "index_of_accepted"
    else
      redirect_to controller: "admin/questions", action: "index_of_open"
    end
  end

  def show
    question = Question.find(params[:id])
    if state_check(question)
      render "admin/questions/working_return"
    else
      super
    end
  end

  # 未検閲の質問一覧
  def index_of_open
    @resource = Question.includes(:student, :subject, :video).open_scope(@admin_user)
    @items = @resource.page(params[:page])
    render "admin/questions/index"
  end

  # 未回答一覧
  def index_of_accepted
    @resource = Question.includes(:student, :subject, :video).accepted_scope(@admin_user)
    @items = @resource.page(params[:page])
    render "admin/questions/index"
  end

  # 保留一覧
  def index_of_pending
    @resource = Question.includes(:student, :subject, :video).pending_scope
    @items = @resource.page(params[:page])
    render "admin/questions/index"
  end

  # 昨日以前に作られた未回答質問一覧
  def index_of_auto_assign
    @resource = Question.includes(:student, :subject, :video).auto_assign_scope
    @items = @resource.page(params[:page])
    render "admin/questions/index"
  end

  # 未承認一覧
  def index_of_answered_unchecked
    @resource = Question.includes(:student, :subject, :video).answered_unchecked_scope(@admin_user)
    @items = @resource.page(params[:page])
    render "admin/questions/index"
  end

  # 検閲履歴
  def history_for_examined
    @resource = Question.includes(:student, :subject, :video).examined_scope(@admin_user)
    @items = @resource.page(params[:page])
    render "admin/questions/index"
  end

  # 回答履歴
  def history_for_answered
    @resource = Post.includes(question: [:student, :subject, :video]).history_for_answered_scope(@admin_user)
    @items = @resource.page(params[:page])
    render "admin/questions/index"
  end

  # 承認履歴
  def histroy_for_answered_checked
    @resource = Post.includes(question: [:student, :subject, :video]).where(executive_answerer_id: @admin_user, state: ["rejected", "accepted_unread", "accepted_read"], refuse_reason_from_gatekeeper: nil).order("created_at DESC")
    @items = @resource.page(params[:page])
    render "admin/questions/index"
  end

  # 検閲中の質問
  def examining
    @resource = Question.where(gatekeeper_id: @admin_user, state: "examining")
    @items = @resource.page(params[:page])
    render "admin/questions/index"
  end

  # 回答中の質問
  def assigned
    @resource = Question.where(answerer_id: @admin_user, state: "assigned")
    @items = @resource.page(params[:page])
    render "admin/questions/index"
  end

  # 承認作業中の質問
  def checking
    question_ids = Post.where(executive_answerer_id: @admin_user, state: "draft").map(&:question_id)
    @resource = Question.where(id: question_ids, state: "checking")
    @items = @resource.page(params[:page])
    render "admin/questions/index"
  end

  # 検閲作業を始める
  def examine
    @item = Question.find(params[:id])
    if @item.can_examine? && @item.gatekeeper_id.nil?
      @item.examine
      @item.update_attributes(gatekeeper_id: @admin_user.id)
      flash.now[:notice] = "検閲作業中です。"
    elsif @item.state == "examining" && @item.gatekeeper_id == @admin_user.id
      render "admin/questions/examine"
    else
      path = { controller: "admin/questions", action: :index }
      redirect_to path, notice: "他の作業者が検閲中です"
    end
  end

  # 検閲をやめる
  def stop_examine
    question = Question.find(params[:id])
    if question.can_stop_examine? && (question.gatekeeper_id == @admin_user.id)
      question.stop_examine
      path = { controller: "admin/questions", action: :index }
      redirect_to path, notice: "検閲作業をやめました。"
    else
      path = { controller: "admin/questions", action: :index }
      redirect_to path, notice: "検閲作業をやめることはできません。"
    end
  end

  # 質問を拒否する
  def refuse
    question = Question.find(params[:id])
    path = { controller: "admin/questions", action: :show, id: params[:id]}
    if question.can_refuse? && question.gatekeeper_id == @admin_user.id
      question.refuse_and_post_refuse_reason(params["refuse_reason_select"], params["refuse_reason_text"].first, @admin_user)
      redirect_to path, notice: "質問 id: #{question.id}を差し戻しました"
    else
      redirect_to path, alert: "質問 id: #{question.id}を差し戻しできませんでした"
    end
  end

  # 質問を受理する
  def accept
    question = Question.find(params[:id])
    path = { controller: "admin/questions", action: :show, id: params[:id]}
    if question.can_accept? && question.gatekeeper_id == @admin_user.id
      question.accept
      redirect_to path, notice: "質問 id: #{question.id}を承認しました"
    else
      redirect_to path, alert: "質問 id: #{question.id}は承認できません。"
    end
  end

  # 質問を保留にする
  def pending
    question = Question.find(params[:id])
    path = { controller: "admin/questions", action: :index_of_pending }
    if question.can_be_pending? && question.gatekeeper_id == @admin_user.id
      question.pending_and_add_pending_reason(params["pending_reason_text"].first)
      redirect_to path, notice: "質問 id: #{question.id}を保留にしました"
    else
      redirect_to path, alert: "質問 id: #{question.id}を保留にできませんでした。"
    end
  end

  # 回答作業を始める
  def assign
    @item = Question.find_by(id: params[:id])
    if @item.can_assign? && !can_not_assign? && @item.answerer_id.nil?
      @item.assign_and_create_post(@admin_user)
      path = { controller: "admin/posts", action: :answer , id: @item.posts.find_by(postable: @admin_user).id}
      redirect_to path, notice: "回答作業中です。"
    elsif @item.state == "assigned" && @item.answerer_id == @admin_user.id
      redirect_to({ controller: "admin/posts", action: :answer , id: @item.posts.find_by(postable: @admin_user).id})
    else
      path = { controller: "admin/questions", action: :index }
      redirect_to path, alert: "質問 id: #{@item.id}には回答できません。"
    end
  end

  # 回答作業をやめる
  def deassign
    question = Question.find_by(id: params[:id])
    path = { controller: "admin/questions", action: :index }
    if question.can_deassign? && question.answerer_id == @admin_user.id
      question.deassign
      redirect_to path, notice: "質問 id: #{question.id}の回答をやめました。"
    else
      redirect_to path, alert: "質問 id: #{question.id}はアサインを外すことができません。"
    end
  end

  # 承認作業を始める
  def work
    question = Question.find_by(id: params[:id])
    post = question.posts.where(postable_type:  "AdminUser", auto_reply: false).last
    if question.can_work? && @admin_user.role != "answerer" && question.answerer != @admin_user
      question.work
      post.update_attributes(executive_answerer_id: @admin_user.id)
      path = { controller: "admin/posts", action: :check , id: post.id }
      redirect_to path, notice: "承認作業を始めます"
    elsif question.state == "checking" && post.executive_answerer_id == @admin_user.id
      redirect_to({ controller: "admin/posts", action: :check , id: post.id})
    else
      path = { controller: "admin/questions", action: :index }
      redirect_to path, alert: "質問 id: #{question.id}はチェックすることができません。"
    end
  end

  # 承認作業をやめる
  def stop_work
    question = Question.find_by(id: params[:id])
    post = question.posts.where(postable_type:  "AdminUser", auto_reply: false).last
    if question.can_stop_work? && @admin_user.role != "answerer" && question.answerer != @admin_user
      question.stop_work
      path = { controller: "admin/questions", action: :index }
      redirect_to path, notice: "承認作業をやめました"
    else
      path = { controller: "admin/questions", action: :index , scopes: "answered_unchecked" }
      redirect_to path, alert: "承認作業をやめることはできません。"
    end
  end

  def force_reject_edit
    @item = Question.find(params[:id])
    @item.update_attributes gatekeeper_id: @admin_user.id
  end

  # 承認者・管理者のみいつでも質問をrejectできる
  def force_reject
    question = Question.find(params[:id])
    path = { controller: "admin/questions", action: :show, id: params[:id]}
    if  question.can_force_reject? && question.gatekeeper_id == @admin_user.id
      question.force_reject_and_create_post(params["refuse_reason_select"], params["refuse_reason_text"].first, @admin_user)
      redirect_to path, notice: "質問 id: #{question.id}を差し戻しました"
    else
      redirect_to path, alert: "質問 id: #{question.id}を差し戻しできませんでした"
    end
  end

  private

    # roleがanswererのAdminUserは一人一つまでの質問にしかアサインできない。
  def can_not_assign?
    @admin_user.role == "answerer" && Question.where(answerer_id: @admin_user.id, state: "assigned").count != 0
  end

  def state_check(question)
    case question.state
    when "examining"
      (question.gatekeeper_id == @admin_user.id)
    when "assigned"
      (question.answerer_id == @admin_user.id)
    when "checking"
      post = question.posts.where(state: "draft", auto_reply: false, postable_type: "AdminUser").last
      (post.executive_answerer_id == @admin_user.id)
    else
      false
    end
  end
end
