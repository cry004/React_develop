class Admin::StudentsController < Admin::ResourcesController
  def index
    add_resource_action('見る', { action: 'show' })
    @resource = Student.page(params[:page])
    @user_static = UserStatic.instance
    super
    if search_param.present?
      @students = Search::Student.new(search_param)
      @items = @students.matches.page(params[:page])
      if params.include?(:member_type_state)
        search_param_values = search_param.values
        @selected_current_member_type = search_param_values.first
        @selected_state = search_param_values.second
      else
        @selected = search_param.keys.first
        @text_filter = search_param.values.first
      end
    end
  end

  def update
    delete_blank_student_params
    super
  end

  def change_member_type
    student = Student.find(params[:id])
    path = { controller: 'admin/students', action: :show, id: student.id }
    begin
      student.change_member_type(params[:type])
      notice_message = (params[:type] == 'tester') ? '会員種別をtesterに変更しました。' : '会員種別をtesterから元に戻しました。'
      redirect_to path, notice: notice_message
    rescue => e
      logger.error [e.class, e.message, e.backtrace]
      redirect_to path, alert: '会員種別を変更できませんでした。'
    end
  end

  def csv_download
    student_csv_file_path = Dir.glob(Rails.root.parent.parent.join('shared').join('students-*.csv.zip')).sort.last
    respond_to do |format|
      format.csv do
        if File.exist? student_csv_file_path
          stat = File::stat(student_csv_file_path)
          file_name = student_csv_file_path.split('/').last
          send_file student_csv_file_path, filename: file_name, length: stat.size
        else
          CreateStudentsTableJob.perform_later
          path = { controller: 'admin/students', action: :index }
          redirect_to path, alert: 'csvをダウンロードできませんでした。'
        end
      end
    end
  end

  def csv_of_search
    if search_param.present?
      @students = Search::Student.new(search_param).matches
    else
      @students = Student.all
    end
    respond_to do |format|
      format.html
      format.csv { send_data @students.to_csv_of_search.encode(Encoding::Shift_JIS), type: 'text/csv; charset=shift_jis', filename: "students-#{Time.zone.today}.csv" }
    end
  end

  def do_student_info_rake_task
    path = { controller: 'admin/students', action: :index }
    UpdateStudentInfoJob.perform_later
    slack_message_json = JSON.generate({
      'text'       => "<https://docs.google.com/a/monstar-lab.com/spreadsheets/d/1udx7IfA3Ez5nNVQz5ANBKGGu7SMm82YxS14H-lzSvOE/edit#gid=0|利用者情報シート>を更新します。 (実行した管理者のemail: #{@admin_user.email})",
      'color'      => 'danger',
      'channel'    => Settings.slack_notify_channel.student_info_task,
      'username'   => 'notification',
      'icon_emoji' => ':trysan:'
    })
    SeedUtils::SpreadsheetUtil.post_to_slack(slack_message_json)
    redirect_to path, notice: 'バックグラウンドで利用者情報シート更新の処理を実行中です。'
  end

  def search_param
    if params[:member_type_state].present?
      params.require(:member_type_state).permit(:current_member_type, :state)
    else
      params.permit(Search::Student::ATTRIBUTES)
    end
  end

  def segment_params
    params.require(:news).permit(prefecture_codes: [], member_types: [], gknn_cds: [])
  end

  def delete_blank_student_params
    params[:student].delete_if { |k, v| v.blank? }
  end

  def student_ids
    students =
      if params[:news]
        Search::Student.new(segment_params).search_by_segment
      else
        Student.all
      end
    render json: students.pluck(:id)
  end
end
