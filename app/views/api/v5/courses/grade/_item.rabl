object false

node(:grade)    { @object[:grade] }
node(:subjects) { partial 'v5/courses/grade/subject/_collection', object: @object[:course] }
