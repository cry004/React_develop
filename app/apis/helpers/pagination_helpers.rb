module PaginationHelpers
  # @author tamakoshi
  # @since 20160226
  def current_page
    max_id = params['max_id'] || @pagination_info.first.try(:[], :max_id)
    @pagination_info.find { |data| data[:max_id] == max_id }
                    .try(:[], :page)
  end
end
