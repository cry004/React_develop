module API
  class V5
    class Units < Grape::API
      before do
        authenticate!
        request_variant # may not be necessary
      end

      resource :units do
        desc 'Get unit videos API', headers: API::Root::HEADERS
        params do
          requires :schoolbook_id,     type: Integer, allow_blank: false
          optional :title,             type: String,  allow_blank: true
          optional :title_description, type: String,  allow_blank: true
          at_least_one_of :title, :title_description
        end
        get 'videos', rabl: 'v5/units/index' do
          Video.current_student_id = @current_student.id

          schoolbook = Schoolbook.find(params[:schoolbook_id])

          title       = params[:title].to_s
          description = params[:title_description].to_s

          unit = schoolbook.units.detect do |sub_unit|
            sub_unit['title'] == title &&
              sub_unit['title_description'] == description
          end

          @videos = unit.try!(:[], 'videos')

          video_ids      = @videos.map { |hash| hash['id'] }
          @video_records = Video.includes(:subject,
                                          :sub_unit,
                                          :video_viewings_with_current_student)
                                .where(id: video_ids)

          @watched_video_ids = @current_student.video_viewings
                                               .watched
                                               .pluck(:video_id)
        end
      end
    end
  end
end
