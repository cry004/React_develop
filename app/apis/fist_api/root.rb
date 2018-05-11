module FistAPI
  class Root < Grape::API
    prefix nil

    mount FistAPI::V1

    if Rails.env.in?(%w(development teacher_develop teacher_staging))
      add_swagger_documentation info: { title: 'Try IT FIST API' }
    end
  end
end
