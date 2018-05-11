object false
node(:video_id)               { @object.id }
node(:watched_count)          { @object.video_viewings_with_current_student.size }
node(:subname)                { @object.subtitle }
node(:ensyu_answer_pdf_url)   { @object.ensyu_answer_pdf_url }
node(:syutoku_answer_pdf_url) { @object.syutoku_answer_pdf_url }

extends 'v5/videos/shared/_item', locals: { object: @object }
