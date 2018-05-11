module SubjectHelper

  def name_node(params)
    if params[:name]
      params[:name]
    else
      type = (params[:school] == 'c') ? params[:type] : params[:key]
      Subject::V3::SUBJECT_TYPE[params[:school]][type]
    end
  end

  def name_short_node(name)
    name&.sub('入試対策編 ', '')&.sub(/センター (.+) (スタンダード|ハイレベル)/, '\1')
  end

  def name_html_node(params)
    return if (name = name_node(params)).blank?
    examination_html =  "<p class='exam highschool'>\n"
    examination_html += "  <span class='label'>\\1</span>\n"
    examination_html += "  <span class='type'>\\2</span>\n"
    examination_html += "</p>\n"
    university_html  =  "<p class='exam university'>\n"
    university_html  += "  <span class='label'>\\1試験対策編</span>\n"
    university_html  += "  <span class='type'>\\2</span>\n"
    university_html  += "</p>"

    name.gsub(/Ⅰ|Ⅱ|Ⅲ/, "<span class='roman_num'>\\0</span>")
        .sub(/(入試対策編) (.+)/, examination_html)
        .sub(/(センター) (.+)/, university_html)
        .delete('（）')
  end
end
