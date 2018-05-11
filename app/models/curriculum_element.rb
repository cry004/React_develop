# == Schema Information
#
# Table name: curriculum_elements
#
#  id                       :integer          not null, primary key
#  subject_id               :integer          not null
#  lecturer_id              :integer
#  school                   :string           not null
#  year                     :integer          not null
#  chapter_number           :integer
#  chapter_title            :string
#  chapter_description      :text
#  section_number           :integer
#  section_title            :string
#  section_description      :text
#  lesson_number            :integer
#  lesson_title             :string
#  content_type             :string
#  content_number           :integer
#  content_title            :string
#  youtube_key              :string
#  youtube_query_parameters :string
#  playback_position        :integer
#  markdown_filename        :string
#  markdown_main            :text
#  markdown_summary         :text
#  published                :boolean          default(FALSE)
#  thumbnail_url            :string
#  parent_id                :integer
#  lft                      :integer          not null
#  rgt                      :integer          not null
#  depth                    :integer          default(0), not null
#  children_count           :integer          default(0), not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  markdown_title           :text
#  understanding_count      :integer          default(0), not null
#  chapter_id               :integer
#  section_id               :integer
#  lesson_id                :integer
#  content_description      :text
#  chapter_stop             :boolean          default(FALSE), not null
#  section_stop             :boolean          default(FALSE), not null
#  chapter_seo_caption_text :text
#  video_id                 :integer
#
# Indexes
#
#  index_curriculum_elements_on_chapter_id   (chapter_id)
#  index_curriculum_elements_on_depth        (depth)
#  index_curriculum_elements_on_lecturer_id  (lecturer_id)
#  index_curriculum_elements_on_lesson_id    (lesson_id)
#  index_curriculum_elements_on_lft          (lft)
#  index_curriculum_elements_on_parent_id    (parent_id)
#  index_curriculum_elements_on_rgt          (rgt)
#  index_curriculum_elements_on_section_id   (section_id)
#  index_curriculum_elements_on_subject_id   (subject_id)
#  index_curriculum_elements_on_video_id     (video_id)
#
# Foreign Keys
#
#  fk_rails_ea6b9a70da  (video_id => videos.id)
#

class CurriculumElement < ActiveRecord::Base
end
