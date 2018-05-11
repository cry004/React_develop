module API
  class V5
    class Workbooks < Grape::API
      before do
        authenticate!
        request_variant # may not be necessary
      end

      resource :workbooks do
        desc 'Workbooks API', headers: API::Root::HEADERS
        get rabl: 'v5/workbooks/index' do
          workbooks = Product.includes(:product_photo)
                             .workbooks.onsales
                             .order(:id)
          @workbooks = workbooks.group_by do |workbook|
            { school: workbook.school,
              name:   workbook.subject_name }
          end
        end
      end
    end
  end
end
