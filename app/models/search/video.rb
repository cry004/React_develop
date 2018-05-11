class Search::Video < Search::Base
  attr_accessor :search_param, :search_value

  def initialize(params)
    @search_param = params.keys.first
    @search_value = params.values.first
    @results = ::Video.includes(:video_title_image, :video_subtitle_image, :subject)
  end

  def matches
    case search_param
    when 'video_id' then search_by_video_id
    when 'video_id_contents' then search_by_video_id_contents
    when 'video_double_speed_id_contents' then search_by_video_double_speed_id_contents
    when 'video_title' then search_by_video_title
    when 'video_subtitle' then search_by_video_subtitle
    when 'video_filename' then search_by_video_filename
    end
  end

  def search_by_video_id
    id = search_value.length > 10 ? nil : search_value
    @results.where(id: id.try(:tr, "０-９", "0-9"))
  end

  def search_by_video_id_contents
    @results.where(id_contents: search_value.try(:tr, "０-９", "0-9"))
  end

  def search_by_video_double_speed_id_contents
    @results.where(double_speed_video_id_contents: search_value.try(:tr, "０-９", "0-9"))
  end

  def search_by_video_title
    @results.where(name: search_value)
  end

  def search_by_video_subtitle
    @results.where(subname: search_value)
  end

  def search_by_video_filename
    @results.where(filename: search_value)
  end
end
