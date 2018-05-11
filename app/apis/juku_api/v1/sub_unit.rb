module JukuAPI
  class V1::SubUnit < Grape::API
    before do
      authenticate!
    end

    helpers do
      def full_sub_subjects
        schools      = I18n.t('school')
        sub_subjects = I18n.t('sub_subject')

        sub_subjects.flat_map do |school, subjects|
          subjects.map do |en, ja|
            key, name = case
                        when en.to_s.start_with?('c1', 'c2', 'c3')
                          [en.to_s, ja]
                        when school == :c && en.in?(%i(geography civics history))
                          ["#{school}_sociology_#{en}", ja]
                        else
                          ["#{school}_#{en}", "#{schools[school]}#{ja}"]
                        end
            { sub_subject_key: key, sub_subject_name: name }
          end
        end
      end
    end

    desc 'SubUnit List', headers: JukuAPI::Root::HEADERS

    get :sub_units, rabl: '/sub_units/index' do
      @sub_subjects = full_sub_subjects

      subject_param = params[:sub_subject_key]
      subject = ::Subject.search_by_sub_subject(subject_param)
                         .for_juku.take
      sub_subject = get_subsubjects(subject).find do |hash|
        if subject.name.in?(%w(classics chinese_classics))
          true # we have only 1 subsubject
        else
          subject_param.remove(/^(c(_sociology)?|k)_/) == hash[:sub_subject_key]
        end
      end
      @units = ::Unit.includes(sub_units: :videos)
                     .search_by_sub_subject(subject, sub_subject[:sub_subject_key])
                     .without_others
                     .learning_order
    end
  end
end
