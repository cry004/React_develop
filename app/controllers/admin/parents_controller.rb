class Admin::ParentsController < Admin::ResourcesController
  protect_from_forgery except: [:docomo_users_csv]
  def index
    add_resource_action('退会', { action: 'withdraw' }, { data: { confirm: '退会処理を行います。よろしいですか？' } })
    super
  end

  def destroy
    parent = Parent.find(params[:id])
    path = { controller: 'admin/parents', action: 'index' }
    unless parent.students.present?
      # 子供が紐付いていない場合のみ削除できる。
      parent.destroy
      redirect_to path, notice: "保護者 ID: #{params[:id]}は削除しました。"
    else
      redirect_to path, alert: "保護者 ID: #{params[:id]}は削除できません。"
    end
  end

  def withdraw
    parent = Parent.find(params[:id])
    path = { action: 'index' }
    begin
      parent.withdraw!
      redirect_to path, notice: "保護者 ID: #{params[:id]}を退会させました。"
    rescue
      redirect_to path, alert: "保護者 ID: #{params[:id]}の退会処理でエラーが発生しました。"
    end
  end

  def docomo_users_csv
    file = params[:file]
    begin
      name = file.original_filename
      if (File.extname(name).downcase == '.csv')
        csv_string = CSV.generate('', encoding: "CP932") do |csv|
          CSV.parse(file.read, encoding: "CP932") do |row|
            if (row[0] == 'email')
              csv << ["email", "本会員登録"]
            else
              csv << [row[0], Parent.where(email: row[0]).pluck(:confirmed_at).first.nil? ? 'x' : 'o']
            end
          end
        end
      end
    rescue
      flash[:error] = 'エラーが発生しました'
      redirect_to(:back)
      return
    end

    send_data csv_string, filename: "#{name}"
  end
end
