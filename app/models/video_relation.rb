# == Schema Information
#
# Table name: video_relations
#
#  id                  :integer          not null, primary key
#  video_id            :integer          not null
#  relational_video_id :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_video_relations_on_relational_video_id               (relational_video_id)
#  index_video_relations_on_video_id                          (video_id)
#  index_video_relations_on_video_id_and_relational_video_id  (video_id,relational_video_id) UNIQUE
#


class VideoRelation < ActiveRecord::Base
  belongs_to :relational_video, class_name: "Video"
end
