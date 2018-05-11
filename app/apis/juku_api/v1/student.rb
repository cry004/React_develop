module JukuAPI
  class V1::Student < Grape::API
    before do
      authenticate!
    end

    helpers JukuHelpers

    desc 'Student List', headers: JukuAPI::Root::HEADERS

    get '/classrooms/:id/students', rabl: '/students/index' do
      attrs  = { dst: destination,
                 TMP_CD: params[:id] }
      client = ::FistStriker::Client::GetStudents.new(attrs)
      client.save!

      response_data = client.data

      @periods  = response_data[:periods]
      @students = response_data[:students]

      @periods.each do |period|
        Period.of(classroom_type)
              .find_or_create_by(str_period_id: period[:id],
                                 start_time:    period[:start_time],
                                 end_time:      period[:end_time])
      end
    end
  end
end
