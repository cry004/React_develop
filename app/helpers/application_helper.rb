module ApplicationHelper
  def round_off(position_time)
    if position_time < Settings.round_off_number
      return 1
    else
      quotient = position_time.div(Settings.round_off_number)
      return Settings.round_off_number * quotient
    end
  end

  def mailer_default_url
    (ActionMailer::Base.default_url_options[:protocol] || 'http') + '://' + ActionMailer::Base.default_url_options[:host]
  end

  def hbr(target)
    h(target).gsub(/\r\n|\r|\n/, "<br />").html_safe
  end

  def number_to_jpy(numeric)
    number_to_currency(numeric, unit: '', precision: 0)
  end

  def subject_pdf_url_path(subject)
    subject.high_school_exam_pdf_url
  end

  def default_meta_tags
    {
      site: Settings.site.name,
      reverse: true,
      title: Settings.site.page_title,
      description: Settings.site.page_description,
      keywords: Settings.site.page_keywords,
      canonical: request.original_url,
      og: {
        title: :title,
        type: Settings.site.meta.ogp.type,
        url: request.original_url,
        image: image_url(Settings.site.meta.ogp.image_path),
        site_name: Settings.site.name,
        description: :description,
        locale: 'ja_JP'
      }
    }
  end

  def select_error(object, attribute)
    return nil if object.nil? || (messages = object.errors.messages[attribute]).nil?
    lis = messages.map do |message|
      %{<li>#{object.class.human_attribute_name attribute}#{message}</li>}
    end.join
    %{<ul class="errors">#{lis}</ul>}.html_safe
  end
end
