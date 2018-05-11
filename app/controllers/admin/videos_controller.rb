class Admin::VideosController < Admin::ResourcesController
  def index
    add_resource_action("見る", { action: "show" })
    add_resource_action("PDFの差し替えを行う", { action: "pdf_replace" })
    if search_param.present?
      @videos = Search::Video.new(search_param)
      @items = @resources = @videos.matches.order("id").page(params[:page]).per(100)
    else
      @items = @resources = Video.includes(:video_title_image, :video_subtitle_image, :subject).where(subject: subject_params, schoolyear: schoolyear_params).order("id").page(params[:page]).per(100)
    end
  end

  def show
    prepend_resources_action("PDFの差し替えを行う", { action: "pdf_replace" })
    super
  end

  def pdf_replace
    @video = Video.find(params[:id])
    @pdf_types = pdf_types
    @select_option_for_pdf_types = pdf_types.map { |type| [type, Settings.pdf_types.to_h.invert[type]]}
  end

  def pdf_upload
    video = Video.find(params["video_id"])
    if validate_pdf_name(video, params)
      AdminUtils::S3.pdf_upload(params["pdf"], video, params[:type])
      redirect_to ({ action: "index" }), notice: "動画ID: #{video.id}のPDFを差し替えました"
    else
      redirect_to ({ action: "pdf_replace", id: video.id }), alert: "PDFファイル名が不正です。"
    end
  end

  def typeset
    begin
      video = Video.find(params[:id])
      if params["type"] == "VideoTitleImage"
        Tex.typeset(params["tex_text"], video, params["type"], params["height_ratio"])
      else
        Tex.typeset(params["tex_text"], video, params["type"], params["height_ratio"])
      end
      redirect_to ({ action: "show", id: video.id }), notice: "組版画像を作成しました"
    rescue => e
      Rails.logger.error [e.class, e.message, e.backtrace]
      redirect_to ({ action: "show", id: video.id }), alert: "組版画像の作成に失敗しました"
    end
  end

  private

  def validate_pdf_name(video, params)
    case params[:type]
    when "checktests"
      video.checktest.split("/").last == params["pdf"].try(:original_filename)
    when "answers"
      video.answer_url.split("/").last == params["pdf"].try(:original_filename)
    when "lessontexts"
      video.lessontext["url"].split("/").last == params["pdf"].try(:original_filename)
    when "notebooks"
      video.notebook_url == params["pdf"].try(:original_filename)
    else
      false
    end
  end

  def validate_video_filename(video, params)
    video.filename == params["video_file"].original_filename
  end

  def search_param
    params.select{|k, v| k.in?(["video_id", "video_id_contents", "video_double_speed_id_contents", "video_title", "video_subtitle", "video_filename"])}
  end

  def subject_params
    available_subjects = Subject.where(for_video: true)
    if available_subjects.map(&:full_name).include? params[:subject]
      available_subjects.find { |subject| subject.full_name == params[:subject] }.id
    else
      available_subjects.map(&:id)
    end
  end

  def schoolyear_params
    all_schoolyear = %w(c1 c2 c3 k call)
    if all_schoolyear.include? params[:schoolyear]
      params[:schoolyear]
    else
      all_schoolyear
    end
  end

  def pdf_types
    if @video.schoolyear.first == 'c'
      if @video.subject.type == 'exam'
        Settings.pdf_types.to_h.select{|type, value| type.in?([:checktest, :answer])}.values
      else
        Settings.pdf_types.to_h.values
      end
    else
      Settings.pdf_types.to_h.select{|type, value| type.in?([:lesson_text, :notebook])}.values
    end
  end
end
