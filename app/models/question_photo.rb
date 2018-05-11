# == Schema Information
#
# Table name: photos
#
#  id                  :integer          not null, primary key
#  type                :string
#  resource_url        :string
#  position            :integer
#  id_video_thumbnail  :string
#  video_id            :integer
#  height              :integer
#  width               :integer
#  height_ratio        :float
#  image_uid           :string
#  image_name          :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  typesetting_flag    :boolean          default(FALSE)
#  product_id          :integer
#  tex_text            :string           default("")
#  image_thumbnail_uid :string
#  data_size           :integer
#  data_width          :integer
#  data_height         :integer
#
# Indexes
#
#  index_photos_on_video_id  (video_id)
#
# Foreign Keys
#
#  fk_rails_a4b7ae9c5b  (video_id => videos.id)
#




class QuestionPhoto < Photo
  include PhotoHelper
  dragonfly_accessor :image do |n|
    copy_to(:image_thumbnail){|a| a.thumb('300x200') }
    copy_to(:image) do |a|
      long_side = (a.width >= a.height) ? a.width : a.height
      (long_side > 1200) ? a.thumb('1200x1200') : a
    end
  end
  dragonfly_accessor :image_thumbnail
end
