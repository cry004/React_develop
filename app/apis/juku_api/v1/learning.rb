module JukuAPI
  class V1::Learning < Grape::API
    before do
      authenticate!
    end

    helpers JukuHelpers

    desc 'Learnings List', headers: JukuAPI::Root::HEADERS

    get '/students/:id/learnings', rabl: '/learnings/index' do
      cache_control :no_store, :must_revalidate, max_age: 0
      status = params[:status]

      @student   = ::Student.find(params[:id])
      @learnings = ::Learning.includes(sub_unit: [{ videos: :youtube_video }, { unit: :subject }])
                             .where(student: @student, box_id: params[:box_id])
      @learnings = @learnings.where(status: status) if status

      array_of_sub_unit_ids = @learnings.pluck(:sub_unit_id)
      @sub_units = SubUnit.includes(:videos).where(id: array_of_sub_unit_ids).order(:sort)

      array_of_unit_ids = @sub_units.pluck(:unit_id)
      @units = Unit.where(id: array_of_unit_ids).order(:sort)
    end

    desc 'Learning Histories List', headers: JukuAPI::Root::HEADERS

    get '/students/:id/learnings/histories', rabl: '/learnings/histories' do
      start_date = params[:start_date]&.to_date || Time.zone.today
      end_date   = params[:end_date]&.to_date   || 3.months.since

      @subjects  = ::Subject.for_juku
      @learnings = ::Learning.includes(:period, sub_unit: [{ unit: :subject }, { videos: :youtube_video }])
                             .where(student_id: params[:id],
                                    reported_at: start_date..end_date.tomorrow)
                             .order('reported_at DESC', 'subjects.sort', 'units.schoolyear', 'units.sort', 'sub_units.sort')
      @learnings = @learnings.where(status: params[:status] || %i(pass failure))

      if (subject_id = params[:subject_id])
        ids = ::Subject.find(subject_id).child_ids
        @learnings = @learnings.where(subjects: { id: ids })
      end

      return if @learnings.blank?

      @learnings = @learnings.group_by do |learning|
        { box_id:       learning.box_id,
          agreement_id: learning.agreement_id,
          date:         learning.sent_on,
          period:       learning.period,
          reported_at:  learning.reported_at }
      end

      @learnings = Array(@learnings)
    end

    desc 'Update Learning', headers: JukuAPI::Root::HEADERS

    put '/learnings', rabl: '/learnings/put' do
      @learning = if params[:learning_id]
                    ::Learning.find(params[:learning_id])
                  else
                    period = Period.of(classroom_type).find_by!(str_period_id: params[:period_id])
                    ::Learning.new(student_id:   params[:student_id],
                                   sub_unit_id:  params[:sub_unit_id],
                                   agreement_id: params[:agreement_id],
                                   period:       period)
                  end

      case params[:status]
      when 'scheduled'
        student  = @learning.student
        sub_unit = @learning.sub_unit

        @learning.cancel!

        videos = ::Video.search_sent_learnings(params[:agreement_id])
        @sum_duration = videos.sum_duration

        return if ::Learning.find_by(id: @learning.id).present?

        recent = ::Learning.where(student: student, sub_unit: sub_unit)
                           .order('created_at DESC')
                           .first
        new    = ::Learning.new(sub_unit_id: @learning.sub_unit_id)
        @learning = recent || new
      when 'sent'
        @learning.box_id  = params[:box_id]
        @learning.sent_on = params[:sent_on].to_date
        @learning.to_sent!
      when 'resent'
        @learning.box_id  = params[:box_id]
        @learning.sent_on = params[:sent_on].to_date
        @learning = @learning.resend!
      end

      videos = ::Video.search_sent_learnings(params[:agreement_id])
      @sum_duration = videos.sum_duration
    end
  end
end
