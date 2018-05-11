object false

node(:course_name)       { @course_name }
node(:trophies_progress) { @courses_progress[:trophies_progress] }
node(:videos_progress)   { @courses_progress[:videos_progress] }

node(:grade) { partial 'v5/courses/grade/_collection', object: @courses }
