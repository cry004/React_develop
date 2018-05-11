module API
  class V5
    class News < Grape::API
      before do
        authenticate!
        request_variant # may not be necessary
      end

      resource :news do
        desc 'News List API', headers: API::Root::HEADERS
        params do
          optional :max_id,   type: Integer,
                              desc: 'The last ID of previous response.'
          optional :per_page, type: Integer, default: 20,
                              desc: 'Number of results to return per page.',
                              max_value: 20
        end
        get rabl: 'v5/news/index' do
          published_at = ::News.find_by(id: params[:max_id])&.published_at
          news  = @current_student.news.published.recent.select_for_list
          @news = news.older(published_at).limit(params[:per_page])
        end

        desc 'News Detail API', headers: API::Root::HEADERS
        get '/:id', rabl: 'v5/news/show' do
          @news = ::News.published.find(params[:id])
        end

        desc 'News Read API', headers: API::Root::HEADERS
        put '/:id/reads' do
          news = NewsStudent.find_by!(news: params[:id], student: @current_student)
          if news.unread
            news.update(unread: false)
            Device.notify_silent(@current_student) if is_pc?
            true
          else
            error('CanNotRead', 'Have been readed news.', 204, true, 'error')
          end
        end
      end
    end
  end
end
