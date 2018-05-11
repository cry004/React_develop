module API
  class V5
    class SearchedWords < Grape::API
      before do
        authenticate!
        request_variant # may not be necessary
      end

      resource :searched_words do
        desc 'SearchedWords List API', headers: API::Root::HEADERS
        get do
          words = SearchedWord.where(student: @current_student)
                              .order(updated_at: :desc)
                              .pluck(:name, :value)
                              .uniq
                              .map do |name, value|
                                { name: name, values: [value] }
                              end
          # Stop using rabl for performance
          { meta: { code: 200, access_token: @access_token },
            data: { words: words } }
        end

        desc 'POST SearchedWords API', headers: API::Root::HEADERS
        params do
          requires :searched_word, type: String, allow_blank: false, description: 'SearchedWord'
        end
        post do
          searched_word =
            SearchedWord.find_or_initialize_by(student: @current_student,
                                               name:    params[:searched_word])
          searched_word.save
          searched_word.touch # always update updated_at column
        end
      end
    end
  end
end
