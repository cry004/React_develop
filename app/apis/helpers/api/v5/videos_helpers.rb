module API::V5::VideosHelpers
  include LearningProgressHelper

  def add_videos_for_each_unit(units, videos)
    units.each do |unit|
      ids = unit['videos'].flat_map { |video| video['id'] }
      videos_for_unit = videos.select{ |video| ids.include? video.id }.uniq
      unit['videos']  = videos_for_unit
      unit['total_videos_count']     = videos_for_unit.size
      unit['completed_videos_count'] = videos_for_unit.count { |video| video.video_viewings_with_current_student.present? }
      unit['completed']              = unit['completed_videos_count'] == unit['total_videos_count']
    end
  end

  def trophies_progress(units)
    units_completed = units.count { |unit| unit['completed_videos_count'] == unit['total_videos_count'] }
    { completed_trophies_count: units_completed, total_trophies_count: units.size }
  end

  def videos_progress(units)
    count_videos_watched = 0
    count_total_videos   = 0

    units.each do |unit|
      count_videos_watched += unit['completed_videos_count']
      count_total_videos   += unit['total_videos_count']
    end
    { completed_videos_count: count_videos_watched, total_videos_count: count_total_videos }
  end

  def find_videos_suggest(units, videos_progress)
    total_videos_completed = videos_progress[:completed_videos_count]
    return { type: 'new', videos: [units.first['videos'].first] } if total_videos_completed.zero?

    find_index = 0
    video_last_watch = nil
    videos = units.map{|unit| unit['videos']}.flatten
    videos.each_with_index do |video, index|
      last_watched_current_video = video.video_viewings_with_current_student.last
      next if last_watched_current_video.blank?
      next unless find_index.zero? || video_last_watch.created_at < last_watched_current_video.created_at
      video_last_watch = last_watched_current_video
      find_index = index
    end
    videos_suggest = [videos[find_index]]
    videos_suggest = [videos[find_index - 1]] + videos_suggest unless find_index.zero?
    if find_index == videos.size - 1
      type = 'end'
    else
      videos_suggest += [videos[find_index + 1]]
      type = 'learning'
    end
    { type: type, videos: videos_suggest }
  end

  def belonging_unit(schoolbook, video)
    unit = belonging_to_unit(schoolbook, video)
    unit&.merge(schoolyear: schoolbook.year, subject_id: schoolbook.subject_id, schoolbook_id: schoolbook.id)
  end

  def searched_keyword(keyword)
    convert_for_value_search(keyword)
      .split(' ')
      .map { |val| "%#{val}%" }
  end

  def searched_videos(keywords)
    Video.includes(:video_tags).where('video_tags.values::jsonb::text LIKE ALL (array[?])', keywords).order('video_tags.priority ASC')
  end

  def convert_for_value_search(keyword)
    NKF.nkf('-XWw', keyword).tr('０-９Ａ-Ｚａ-ｚA-Zァ-ン　', '0-9a-za-za-zぁ-ん ')
  end

  def find_trophies_progress(video_viewing, schoolbook, watched_videos_id)
    return nil unless video_viewing.unit_trophy_flag
    video = video_viewing.video
    units_size = schoolbook.units.size
    return { completed_trophies_count: units_size, total_trophies_count: units_size } if video_viewing.schoolbook_trophy_flag
    study_book_progress = progress_with_a_schoolbook(schoolbook, watched_videos_id)
    { completed_trophies_count: study_book_progress[:completed_trophies_count],
      total_trophies_count:     study_book_progress[:total_trophies_count] }
  end
end
