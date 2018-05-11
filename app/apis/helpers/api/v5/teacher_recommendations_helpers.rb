module API::V5::TeacherRecommendationsHelpers
  def current_recommendation
    @current_student.teacher_recommendations.find_by!(id: params[:id])
  end

  def all_videos_for_recommendation(recommendation)
    recommendation.teacher_recommendation_videos
                  .includes(
                    video: [
                      :subject,
                      :sub_unit,
                      :video_viewings_with_current_student
                    ])
  end

  def add_types_and_count_viewed(recommend_videos)
    return_videos = recommend_videos.map do |recommend_video|
      video = recommend_video.video
      add_video_types(video, recommend_video.video_type)
      add_count_of_viewed(video)
      video
    end
    return_videos.sort_by(&sort_by_block)
  end

  def add_video_types(video, video_type)
    video.recommend_type = video_type
  end

  def add_count_of_viewed(video)
    video.count_of_viewed = video.video_viewings_with_current_student.size
  end

  def sort_by_block
    lambda do |video|
      case video.recommend_type
      when 'review' then 1
      when 'preparation' then 2
      else 0
      end
    end
  end
end
