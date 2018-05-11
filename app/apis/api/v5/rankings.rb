module API
  class V5
    class Rankings < Grape::API
      helpers do
        include LearningProgressesHelpers
      end

      before do
        authenticate!
        request_variant # may not be necessary
      end

      resource :rankings do
        desc 'Student rankings overview API', headers: API::Root::HEADERS
        params do
          optional :period_type, type: String, values: %w(last_7_days last_month)
        end
        get '/personals', rabl: 'v5/rankings/personals' do
          @ranking = case params[:period_type]
                     when 'last_7_days'   then Ranking::Daily.students.recent.take
                     when 'last_month'    then Ranking::Monthly.students.recent.take
                     else Ranking::Daily.students.recent.take
                     end
          @rank             = @ranking && @ranking.ranks.find_by(ranker: @current_student)
          @ranking_month    = @ranking&.last_month
          prefecture_code   = @current_student.school_prefecture_code
          classroom_id      = @current_student.classroom_id
          @prefecture_ranks = @ranking && @ranking.ranks.prefecture_top(3).include_ranker.prefectures(prefecture_code)
          @national_ranks   = @ranking && @ranking.ranks.national_top(3).include_ranker
          @classroom_ranks  = @ranking && @ranking.ranks.classroom_top(3).include_ranker.classrooms(classroom_id)
        end

        desc 'Student ranking detail API', headers: API::Root::HEADERS
        params do
          requires :ranking_type, type: String, values: %w(prefecture national classroom)
          optional :period_type,  type: String, values: %w(last_7_days last_month)
        end
        get '/personal', rabl: 'v5/rankings/personal' do
          @ranking = case params[:period_type]
                     when 'last_7_days'   then Ranking::Daily.students.recent.take
                     when 'last_month'    then Ranking::Monthly.students.recent.take
                     else Ranking::Daily.students.recent.take
                     end
          @rank          = @ranking && @ranking.ranks.find_by(ranker: @current_student)
          @ranking_month = @ranking&.last_month

          case params[:ranking_type]
          when 'prefecture'
            prefecture_code  = @current_student.school_prefecture_code
            @student_ranking = @rank&.prefecture_rank
            @ranking_changes = @rank&.prefecture_rank_variation
            @rankings        = @ranking && @ranking.ranks.prefecture_top(100).include_ranker.prefectures(prefecture_code)
          when 'national'
            @student_ranking = @rank&.national_rank
            @ranking_changes = @rank&.national_rank_variation
            @rankings        = @ranking && @ranking.ranks.national_top(100).include_ranker
          when 'classroom'
            classroom_id     = @current_student.classroom_id
            @student_ranking = @rank&.classroom_rank
            @ranking_changes = @rank&.classroom_rank_variation
            @rankings        = @ranking && @ranking.ranks.classroom_top(30).include_ranker.classrooms(classroom_id)
          end
        end

        desc 'Classroom ranking overview API', headers: API::Root::HEADERS
        params do
          optional :period_type, type: String, values: %w(last_7_days last_month)
        end
        get '/classrooms', rabl: 'v5/rankings/classrooms' do
          case params[:period_type]
          when 'last_month'
            @ranking_classroom   = Ranking::Monthly.classrooms.recent.take
            @ranking_schoolhouse = Ranking::Monthly.schoolhouses.recent.take
          else
            @ranking_classroom   = Ranking::Daily.classrooms.recent.take
            @ranking_schoolhouse = Ranking::Daily.schoolhouses.recent.take
          end
          @classroom = @current_student.classroom
          @rank = case @classroom&.classroom_type
                  when Classroom::TYPE::CLASSROOM
                    @ranking_classroom && @ranking_classroom.ranks.find_by(ranker_id: @classroom.id, ranker_type: 'Classroom::Klassroom')
                  when Classroom::TYPE::SCHOOLHOUSE
                    @ranking_schoolhouse && @ranking_schoolhouse.ranks.find_by(ranker_id: @classroom.id, ranker_type: 'Classroom::Schoolhouse')
                  end
          @ranking_month              = @ranking_classroom&.last_month
          prefecture_code             = @classroom&.prefecture_code
          @prefecture_classroom_ranks = @classroom&.classroom_type == Classroom::TYPE::CLASSROOM ? @ranking_classroom && @ranking_classroom.ranks.prefecture_top(3).include_ranker.prefectures(prefecture_code) : []
          @national_classroom_ranks   = @ranking_classroom && @ranking_classroom.ranks.national_top(3).include_ranker
          @national_schoolhouse_ranks = @ranking_schoolhouse && @ranking_schoolhouse.ranks.national_top(3).include_ranker
        end

        desc 'Classroom ranking detail API', headers: API::Root::HEADERS
        params do
          requires :ranking_type, type: String, values: %w(prefecture national)
          requires :classroom_type, type: String, values: %w(classroom schoolhouse), combination_of_ranking_and_classroom: true
          optional :period_type,  type: String, values: %w(last_7_days last_month)
        end
        get '/classroom', rabl: 'v5/rankings/classroom' do
          case params[:period_type]
          when 'last_month'
            @ranking_classroom   = Ranking::Monthly.classrooms.recent.take
            @ranking_schoolhouse = Ranking::Monthly.schoolhouses.recent.take
          else
            @ranking_classroom   = Ranking::Daily.classrooms.recent.take
            @ranking_schoolhouse = Ranking::Daily.schoolhouses.recent.take
          end
          @classroom = @current_student.classroom
          @rank = case @classroom&.classroom_type
                  when Classroom::TYPE::CLASSROOM
                    @ranking_classroom && @ranking_classroom.ranks.find_by(ranker_id: @classroom.id, ranker_type: 'Classroom::Klassroom')
                  when Classroom::TYPE::SCHOOLHOUSE
                    @ranking_schoolhouse && @ranking_schoolhouse.ranks.find_by(ranker_id: @classroom.id, ranker_type: 'Classroom::Schoolhouse')
                  end

          @ranking_month = @ranking_classroom&.last_month

          case params[:ranking_type]
          when 'prefecture'
            prefecture_code     = @classroom&.prefecture_code
            @classroom_ranking  = @rank&.prefecture_rank
            @ranking_changes    = @rank&.prefecture_rank_variation
            @rankings           = @ranking_classroom && @ranking_classroom.ranks.prefecture_top(100).include_ranker.prefectures(prefecture_code)
          when 'national'
            case params[:classroom_type]
            when Classroom::TYPE::CLASSROOM
              @classroom_ranking  = @rank&.national_rank
              @ranking_changes    = @rank&.national_rank_variation
              @rankings           = @ranking_classroom && @ranking_classroom.ranks.national_top(100).include_ranker
            when Classroom::TYPE::SCHOOLHOUSE
              @classroom_ranking  = @rank&.national_rank
              @ranking_changes    = @rank&.national_rank_variation
              @rankings           = @ranking_schoolhouse && @ranking_schoolhouse.ranks.national_top(100).include_ranker
            end
          end
        end
      end
    end
  end
end
