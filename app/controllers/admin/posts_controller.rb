class Admin::PostsController < Admin::ResourcesController
  # postsの一覧は表示せず、質問の一覧へリダイレクト
  def index
    redirect_to ({ controller: "admin/questions", action: :index })
  end

  # 回答履歴
  def show
    @post = Post.find(params[:id])
  end

  # 回答作成画面
  def answer
    @post = Post.find(params[:id])
    unless (@post.question.state == "assigned") && (@post.question.answerer_id == @admin_user.id)
      redirect_to({ controller: "admin/questions", action: :index })
    end
  end

  # 回答承認画面
  def check
    @post = Post.find(params[:id])
    unless @post.question.state == "checking" && @post.executive_answerer_id == @admin_user.id
      redirect_to({ controller: "admin/questions", action: :index })
    end
  end

  # 回答作成
  def update
    post = Post.find(params[:id])
    if params[:post] && params[:post][:upload_file] && check_upload_file_type(params[:post][:upload_file])
      original_filename = params[:post][:upload_file].original_filename
      extension = original_filename.split(".")[-1]
      params[:post][:upload_file].original_filename = "temp#{Time.zone.now.to_i}#{SecureRandom.uuid}.#{extension}"
      photo = Question.create_question_photo(params[:post][:upload_file])
      post.update_attributes(photo: photo, body: Settings.message_of_teacher_answer)
      unless post.question.deassign_if_one_hour_spent(admin_user)
        path = { controller: "admin/questions", action: :show, id: post.question.id }
        post.question.answer
        redirect_to path, notice: "回答を作成しました"
      else
        path = { controller: "admin/questions", action: :index}
        redirect_to path, alert: "回答中にしてから1時間経過したため、質問 id: #{post.question.id}に回答できませんでした。"
      end
    else
      path = { controller: "admin/posts", action: :answer, id: post.id }
      redirect_to path, alert: "回答の画像を添付してください。"
    end
  end

  # 回答承認・不採用を判断する
  def judge
    post = Post.find(params[:id])
    question = post.question
    if question.can_check? && @admin_user != "answerer" && question.answerer != @admin_user
      if params[:accept]
        post.accept_from_executive_answerer(params[:comment])
        path = { controller: "admin/questions", action: :index }
        redirect_to path, notice: "回答を承認しました"
      else
        new_post = post.unaccept_from_executive_answerer(@admin_user, params["refuse_reason_select"], params["refuse_reason_text"].first)
        path = { controller: "admin/posts", action: :answer, id: new_post.id }
        redirect_to path, notice: "不採用とし、自分で回答を始めます"
      end
    else
      path = { controller: "admin/questions", action: :index }
      redirect_to path, alert: "チェックすることはできません。"
    end
  end

  private

  # PDFかどうかチェックする。
  def check_upload_file_type(upload_file)
    !(upload_file.content_type == "application/pdf")
  end
end
