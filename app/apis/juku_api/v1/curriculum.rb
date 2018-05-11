module JukuAPI
  class V1::Curriculum < Grape::API
    before do
      authenticate!
    end

    helpers JukuHelpers

    desc 'カリキュラム詳細API', headers: JukuAPI::Root::HEADERS

    get '/students/:id/curriculums', rabl: '/curriculums/index' do
      attrs  = { dst: destination,
                 agreement_id: params[:agreement_id] }
      client = ::FistStriker::Client::GetAgreement.new(attrs)
      client.save!

      response_data = client.data

      # NOTE: `agreement_id` isn't included in the response from TryPlus API
      # `agreement_id` of the request parameter is equal to one of the response
      @agreement    = response_data
      @agreement[:agreement_id] ||= params[:agreement_id]

      @box_id       = params[:box_id]
      @student      = ::Student.find(params[:id])
      @subject      = ::Subject.find(params[:subject_id])

      sub_subject = params[:sub_subject_key] ||
                    get_subsubjects(@subject)[0][:sub_subject_key]

      @sub_subjects = get_subsubjects(@subject)
      @curriculum   = ::Curriculum.find_by(agreement_id:    params[:agreement_id],
                                           student:         @student,
                                           sub_subject_key: sub_subject)
      @units        = ::Unit.includes(:subject, sub_units: { videos: [:youtube_video, :subject] })
                            .where.not('units.schoolyear LIKE ?', '%_other')
                            .order(:sort, :id, 'sub_units.sort', 'videos.filename')

      @learnings = ::Learning.includes(sub_unit: { unit: :subject })
                             .where(student:  @student,
                                    subjects: { id: @subject.subtree.pluck(:id) })
      if Subject::EXCEPTION_SUBJECT_KEY.include? sub_subject
        subject_name, subject_type = Subject.get_name_and_type_by_subject_key(sub_subject)
        subject = ::Subject.find_by(school: 'k',
                                    name:   subject_name,
                                    type:   subject_type)
        @units = @units.where(subject: subject)
        @exam_flag = true if subject.university_exam?
      else
        @units = case sub_subject
                 when /^(c.)_.+_regular$/
                   @units.where(schoolyear: Regexp.last_match(1))
                         .where(subject: @subject.children)
                 when /^.+_(standard|high-level)$/
                   @exam_flag = true
                   names = sub_subject.split('_')
                   subject = ::Subject.find_by(school: @subject.school[0],
                                               name:   names[0..-2].join('_'),
                                               type:   names[-1])
                   @exam_flag = true if subject.university_exam?

                   @units.where(subject: subject)
                 else
                   subject = ::Subject.find_by(school: @subject.school,
                                               name: sub_subject,
                                               type: :daily_report)
                   @exam_flag = true if subject.university_exam?
                   @units.where(subject: subject)
                 end
      end
      @todo_learning_ids = to_do_learning_ids

      videos = ::Video.search_sent_learnings(params[:agreement_id])
      @sum_duration = videos.sum_duration
    end

    desc 'Create Curriculum', headers: JukuAPI::Root::HEADERS

    post '/students/:id/curriculums', rabl: '/default' do
      student    = ::Student.find(params[:id])
      period     = ::Period.of(classroom_type).find_by!(str_period_id: params[:period_id])
      curriculum = ::Curriculum.new(
        student:         student,
        agreement_id:    params[:agreement_id],
        agreement_dow:   params[:agreement_dow],
        start_date:      params[:start_date],
        end_date:        params[:end_date],
        period:          period,
        sub_subject_key: params[:sub_subject_key]
      )
      curriculum.build_learnings(sub_unit_ids: params[:sub_unit_ids])
      curriculum.save!
    end

    desc 'Update Curriculum', headers: JukuAPI::Root::HEADERS

    put '/curriculums/:id', rabl: '/default' do
      curriculum = ::Curriculum.find(params[:id])
      curriculum.start_date = params[:start_date]
      curriculum.end_date   = params[:end_date]
      ::ActiveRecord::Base.transaction do
        attrs = { sub_unit_ids: params[:sub_unit_ids] }
        curriculum.build_and_release_learnings!(attrs)
        curriculum.save!
      end
    end

    desc 'Number of Weeks', headers: JukuAPI::Root::HEADERS

    get '/number_of_weeks', rabl: '/curriculums/number_of_weeks' do
      start_date = params[:start_date].to_date
      end_date   = params[:end_date].to_date
      @number_of_weeks = (start_date..end_date).count(&:tuesday?)
    end
  end
end
