extend SubjectHelper
object false

node(:video_id)               { @object.id }
node(:video_name)             { @object.name }
node(:duration)               { @object.duration }
node(:checktest_url)          { checktest? ? @object.checktest : '' }
node(:checktest_answer_url)   { checktest? ? @object.answer_url : '' }
node(:lesson_text_url)        { lesson_text? ? (@object.lesson_text_url || url.gsub('_ans', '')) : '' }
node(:lesson_text_answer_url) { lesson_text? ? (@object.lesson_text_answer_url || url) : '' }
node(:practice_url)           { @object.practice_url }
node(:practice_answer_url)    { @object.practice_answer_url }
node(:textset_url)            { @object.textset_url }
node(:youtube_url)            { "https://www.youtube.com/embed/#{@object.youtube_id}" if @object.youtube_id}

node(:heading_lessontext)     { Settings.lesson_text_base_url + Settings.heading_lessontext }
node(:heading_lessontext_ans) { Settings.lesson_text_base_url + Settings.heading_lessontext_ans }
node(:heading_practice)       { Settings.practice_base_url + Settings.heading_practice }

def url
  @object.notebook_url.gsub('notebooks', 'lessontexts')
end

def checktest?
  @object.schoolyear != 'k'
end

def lesson_text?
  !(@object.schoolyear == 'c' && @exam_flag)
end
