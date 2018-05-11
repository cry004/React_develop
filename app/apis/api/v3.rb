# frozen_string_literal: true

# FIXME: remove me! https://rdm.try-it.jp/issues/4714
module API
  class V3 < Grape::API
    prefix         :api
    format         :json
    default_format :json

    version :v3, using: :path

    resource :utility do
      desc 'List of gknn_cd'
      get '/gknn_cds' do
        data = GknnCd::Map.map { |code, name| { code: code, name: name } }
        { meta: { code: 200 }, data: data }
      end

      desc 'List of school_name'
      get '/school_names' do
        pref_code = params[:prefecture_code]
        category  = GknnCd::CategoryMap[params[:gknn_cd]]
        term      = "%#{params[:term]}%"

        data = School.where(prefecture_code: pref_code,
                            category:        category)
                     .where('name LIKE ? OR kana LIKE ?', term, term)
                     .limit(500)
                     .uniq.pluck(:name)

        { meta: { code: 200 }, data: data }
      end
    end
  end
end
