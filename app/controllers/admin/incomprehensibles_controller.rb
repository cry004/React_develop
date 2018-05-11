class Admin::IncomprehensiblesController < Admin::ResourcesController
  def index
    @items = @resources = Question.unscope(where: :state).includes(:student, :video => :subject).where("students.sit_cd IS NOT NULL AND questions.video_id IS NOT NULL").references(:student).order("questions.created_at DESC").page(params[:page]).per(30)
  end

  def csv_download
    @csv_data = Question.unscope(where: :state).includes(:student, :video => :subject).where("students.sit_cd IS NOT NULL AND questions.video_id IS NOT NULL").where("questions.created_at >= (?) AND questions.created_at < (?)", Time.zone.now.yesterday.beginning_of_day.since(8.hours), Time.zone.now.beginning_of_day.since(8.hours)).references(:student)
    respond_to do |format|
      format.csv do
        send_data render_to_string, filename: "incomprehensibles-#{Time.zone.now.yesterday.strftime('%Y%m%d')}.csv", type: :csv
      end
    end
  end

  def study_log_csv_download
    num = varidate_date_param
    date_label = Time.zone.now.beginning_of_day.ago(num.day).strftime("%Y%m%d")
    file_name = "study_log_fist_#{date_label}_0500-0500.csv.zip"
    student_csv_file_path = Rails.root.parent.parent.join("shared").join(file_name)
    respond_to do |format|
      format.csv do
        if File.exist? student_csv_file_path
          stat = File::stat(student_csv_file_path)
          send_file student_csv_file_path, filename: file_name, length: stat.size
        else
          path = { controller: "admin/incomprehensibles", action: :index }
          redirect_to path, alert: "csvをダウンロードできませんでした。"
        end
      end
    end
  end

  private

  def varidate_date_param
    case params["date"].to_i
    when 0..7 then params["date"].to_i
    else 0
    end
  end
end
