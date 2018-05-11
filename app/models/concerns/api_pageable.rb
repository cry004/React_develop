module ApiPageable
  extend ActiveSupport::Concern

  module ClassMethods
    def api_per_page_num(number)
      @_default_per_page_num = number
    end

    def default_api_per_page_num
      (defined?(@_default_per_page_num) && @_default_per_page_num) ||
        Settings.default_api_per_page_num
    end
  end
end
