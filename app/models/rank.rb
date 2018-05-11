# == Schema Information
#
# Table name: ranks
#
#  id                        :integer          not null, primary key
#  ranking_id                :integer          not null
#  ranker_id                 :integer          not null
#  ranker_type               :string           not null
#  viewed_time               :integer          not null
#  national_rank             :integer          not null
#  prefecture_rank           :integer
#  prefecture_code           :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  national_rank_variation   :integer
#  prefecture_rank_variation :integer
#  classroom_id              :integer
#  classroom_rank            :integer
#  classroom_rank_variation  :integer
#
# Indexes
#
#  index_ranks_on_classroom_id                              (classroom_id)
#  index_ranks_on_prefecture_code                           (prefecture_code)
#  index_ranks_on_ranker_type_and_ranker_id                 (ranker_type,ranker_id)
#  index_ranks_on_ranking_id                                (ranking_id)
#  index_ranks_on_ranking_id_and_class_id_and_class_rank    (ranking_id,classroom_id,classroom_rank) UNIQUE
#  index_ranks_on_ranking_id_and_national_rank              (ranking_id,national_rank) UNIQUE
#  index_ranks_on_ranking_id_and_pref_rank_and_pref_code    (ranking_id,prefecture_rank,prefecture_code) UNIQUE
#  index_ranks_on_ranking_id_and_ranker_id_and_ranker_type  (ranking_id,ranker_id,ranker_type) UNIQUE
#
# Foreign Keys
#
#  fk_rails_1b81c13685  (classroom_id => classrooms.id)
#  fk_rails_ba6938fe35  (ranking_id => rankings.id)
#

class Rank < ActiveRecord::Base
  RANKER_TYPES = [Student, Classroom::Klassroom, Classroom::Schoolhouse].map(&:name)

  belongs_to :ranking, required: true
  belongs_to :ranker,  required: true, polymorphic: true

  scope :include_ranker,   -> { includes(:ranker) }
  scope :national_order,   -> { order(:national_rank) }
  scope :national_top,     -> (num) { where(national_rank: 1..num).national_order.limit(num) }
  scope :prefecture_order, -> { order(:prefecture_rank) }
  scope :prefecture_top,   -> (num) { where(prefecture_rank: 1..num).prefecture_order.limit(num) }
  scope :prefectures,      -> (code) { where(prefecture_code: code) }

  scope :classroom_order,  -> { order(:classroom_rank) }
  scope :classroom_top,    -> (num) { where(classroom_rank: 1..num).classroom_order.limit(num) }
  scope :classrooms,       -> (id) { where(classroom_id: id) }

  validates :ranker_id,       uniqueness: { scope: %i(ranking_id ranker_type) }
  validates :ranker_type,     inclusion:  { in: RANKER_TYPES }
  validates :viewed_time,     presence:   true
  validates :national_rank,   presence:   true,
                              uniqueness: { scope: :ranking_id }
  validates :prefecture_rank, presence:   true, if: :prefecture_code,
                              uniqueness: { scope: %i(ranking_id prefecture_code) }
  validates :prefecture_code, inclusion:  { in: JpPrefecture::Prefecture.all.map(&:code) },
                              allow_nil:  true
  validates :classroom_rank,  presence:   true, if: :classroom_id,
                              uniqueness: { scope: %i(ranking_id classroom_id) }
  validate :national_rank_greater_than_prefecture_rank

  def national_rank_greater_than_prefecture_rank
    return unless prefecture_rank
    errors.add(:national_rank) if national_rank < prefecture_rank
  end
end
