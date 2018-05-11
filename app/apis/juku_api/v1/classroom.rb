module JukuAPI
  class V1::Classroom < Grape::API
    before do
      authenticate!
    end

    helpers JukuHelpers

    desc 'List of Classrooms', headers: JukuAPI::Root::HEADERS

    get :classrooms, rabl: '/classrooms/index' do
      # 都道府県未選択の場合の対応
      return @classrooms = [] if params[:prefecture_code] == '00'

      attrs  = { dst: destination,
                 tdfkn_cd: params[:prefecture_code] }

      client = ::FistStriker::Client::GetClassrooms.new(attrs)
      client.save!

      @classrooms = client.data[:TMPs]
    end
  end
end
