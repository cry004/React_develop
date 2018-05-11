module JukuAPI
  class V1::Box < Grape::API
    before do
      authenticate!
    end

    helpers JukuHelpers

    desc 'Box List', headers: JukuAPI::Root::HEADERS

    get :boxes, rabl: '/boxes/index' do
      default_date = Time.zone.today
      start_date   = params[:start_date]&.to_date || default_date
      end_date     = params[:end_date]&.to_date || default_date

      attrs  = { dst:        destination,
                 TMP_CD:     params[:classroom_id],
                 start_date: start_date.strftime('%Y%m%d'),
                 end_date:   end_date.strftime('%Y%m%d') }
      client = ::FistStriker::Client::GetBoxes.new(attrs)
      client.save!

      @boxes = client.data

      periods = @boxes[:periods]
      periods.each do |period|
        Period.of(classroom_type)
              .find_or_create_by(str_period_id: period[:id],
                                 start_time:    period[:start_time],
                                 end_time:      period[:end_time])
      end
    end
  end
end
