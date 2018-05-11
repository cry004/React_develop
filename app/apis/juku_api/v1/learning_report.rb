module JukuAPI
  class V1::LearningReport < Grape::API
    before do
      authenticate!
    end

    helpers JukuHelpers

    desc 'Learning Report Details', headers: JukuAPI::Root::HEADERS

    get '/boxes/:id/learning_reports', rabl: '/learning_reports/index' do
      attrs  = { dst: destination,
                 agreement_id: params[:agreement_id] }
      client = ::FistStriker::Client::GetAgreement.new(attrs)
      client.save!

      response_data = client.data

      @agreement = response_data
      @box_id    = params[:id]
      @student   = ::Student.find_by!(sit_cd: response_data[:SIT_CD])
      @subject   = ::Subject.find(params[:subject_id])

      includes = { learnings: [:curriculum, sub_unit: [{ unit: :subject }, { videos: :youtube_video }]] }
      @reports = ::LearningReport.includes(includes)
                                 .where(agreement_id: params[:agreement_id],
                                        student:      @student,
                                        reported_at:  params[:reported_at])
                                 .order('subjects.sort', 'units.schoolyear', 'units.sort', 'sub_units.sort')

      learnings    = @reports.take&.learnings
      @report_date = learnings&.take&.sent_on

      sub_units = ::SubUnit.includes(:learnings)
                           .where(learnings: { id: learnings&.pluck(:id) })
      passes    = sub_units.where(learnings: { status: :pass }).pluck(:id)
      e_navis   = ::ENavi.includes(:sub_units)
                         .where(sub_units: { id: sub_units.pluck(:id) })
                         .order(:fist_subject_id, :section_id, :content_id)
      @e_navis  = e_navis.group_by do |e_navi|
        ids = e_navi.sub_units.pluck(:id)
        ids.all? { |sub_unit| sub_unit.in?(passes) } ? :reviews : :challenges
      end
    end

    desc 'Create Learning Report', headers: JukuAPI::Root::HEADERS

    post '/learning_reports', rabl: 'default' do
      box_id       = params[:box_id]
      reported_at  = params[:reported_at]
      agreement_id = params[:agreement_id]

      student   = ::Student.find(params[:student_id])
      learnings = ::Learning.includes(sub_unit: [{ videos: :youtube_video }, { unit: :subject }])
                             .where(student: student, box_id: box_id, status: :sent)
      if learnings.blank?
        error('NoData', 'there is no data to change status.', 400, false, 'info')
      end

      learnings.each do |learning|
        learning.box_id      = box_id
        learning.reported_at = reported_at
      end

      ActiveRecord::Base.transaction do
        ::LearningReport.build_reports!(learnings, agreement_id)
        learnings.each(&:pass!)
      end
    end
  end
end
