# == Schema Information
#
# Table name: carousels
#
#  id                    :integer          not null, primary key
#  request_path          :string           not null
#  sort                  :integer          default(0), not null
#  curriculum_element_id :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_carousels_on_request_path  (request_path)
#  index_carousels_on_sort          (sort)
#


class Carousel < ActiveRecord::Base
end
