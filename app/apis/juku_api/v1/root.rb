module JukuAPI
  class V1::Root < Grape::API
    version 'v1'
    format :json
    formatter :json, Grape::Formatter::Rabl

    before do
      change_root_view_path
    end

    helpers do
      def change_root_view_path
        env['api.tilt.root'] = 'app/views/juku_api/v1'
      end
    end

    mount V1::Box
    mount V1::Classroom
    mount V1::Curriculum
    mount V1::Learning
    mount V1::LearningReport
    mount V1::Student
    mount V1::SubUnit
  end
end
