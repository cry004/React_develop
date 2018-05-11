module API
  class V5
    class VideoTags < Grape::API
      before do
        authenticate!
        request_variant # may not be necessary
      end

      resource :video_tags do
        desc 'VideoTags List API', headers: API::Root::HEADERS
        get do
          tags = VideoTag.order(priority: :asc)
                         .pluck(:name, :values)
                         .uniq
                         .group_by { |name, _values| name }.flat_map do |name, values|
                           { name: name, values: values.flat_map { |_name, values| values }.uniq }
                         end
          # Stop using rabl for performance
          { meta: { code: 200, access_token: @access_token },
            data: { tags: tags } }
        end
      end
    end
  end
end
