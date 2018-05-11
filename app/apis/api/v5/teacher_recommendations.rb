module API
  class V5
    class TeacherRecommendations < Grape::API
      include Grape::Kaminari
      helpers TeacherRecommendationsHelpers

      before do
        authenticate!
        request_variant # may not be necessary
      end

      resource :teacher_recommendations do
        paginate per_page: 20, max_per_page: 20, offset: false
        desc 'TeacherRecommendations List API', headers: API::Root::HEADERS
        get rabl: 'v5/teacher_recommendations/index' do
          recommendations = @current_student.teacher_recommendations
                                            .includes(:teacher)
                                            .order(id: :desc)

          @recommendations = paginate(recommendations).page(params[:page])
                                                      .per(params[:per_page])
        end

        desc 'TeacherRecommendation Detail API', headers: API::Root::HEADERS
        get '/:id', rabl: 'v5/teacher_recommendations/show' do
          Video.current_student_id = @current_student.id
          @recommendation          = current_recommendation
          all_recommend_videos     = all_videos_for_recommendation(@recommendation)
          @recommended_videos      = add_types_and_count_viewed(all_recommend_videos)
        end

        desc 'Read recommendation from a teacher', headers: API::Root::HEADERS
        put '/:id/reads' do
          recommendation = current_recommendation
          if recommendation.unread
            recommendation.update(unread: false)
            Device.notify_silent(@current_student) if is_pc?
            true
          else
            error('CanNotRead', 'Have been readed teacher_recommendations.', 204, true, 'error')
          end
        end
      end
    end
  end
end
