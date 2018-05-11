module API
  class V5
    class Courses < Grape::API
      helpers CoursesHelpers
      before do
        authenticate!
        request_variant # may not be necessary
      end

      resource :courses do
        desc 'Get Courses API', headers: API::Root::HEADERS
        params do
          requires :course_name, type: String, values: I18n.t('courses_name').keys.map(&:to_s), description: 'Course name'
          optional :grade, type: String, values: %w(c k), allow_blank: true, description: 'Grade'
        end
        get rabl: 'v5/courses/index' do
          Video.current_student_id = @current_student.id
          @course_name = params[:course_name]
          @courses =
            if params[:grade]
              [{ grade: params[:grade], course: find_course(@course_name, params[:grade]) }]
            else
              [{ grade: 'c', course: find_course(@course_name, 'c') },
               { grade: 'k', course: find_course(@course_name, 'k') }]
            end
          @courses_progress = find_courses_progress(@courses)
        end
      end
    end
  end
end
