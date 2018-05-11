# == Schema Information
#
# Table name: learnings
#
#  id                 :integer          not null, primary key
#  student_id         :integer          not null
#  sub_unit_id        :integer          not null
#  curriculum_id      :integer
#  box_id             :integer
#  status             :string           not null
#  sent_on            :date
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  reported_at        :datetime
#  period_id          :integer          not null
#  agreement_id       :string           not null
#  learning_report_id :integer
#
# Indexes
#
#  index_learnings_on_agreement_id        (agreement_id)
#  index_learnings_on_box_id              (box_id)
#  index_learnings_on_curriculum_id       (curriculum_id)
#  index_learnings_on_learning_report_id  (learning_report_id)
#  index_learnings_on_period_id           (period_id)
#  index_learnings_on_student_id          (student_id)
#  index_learnings_on_sub_unit_id         (sub_unit_id)
#
# Foreign Keys
#
#  fk_rails_40c1906a5c  (learning_report_id => learning_reports.id)
#  fk_rails_809efdb2a7  (curriculum_id => curriculums.id)
#  fk_rails_825750ef5a  (period_id => periods.id)
#  fk_rails_962c2f0b7d  (student_id => students.id)
#

class Learning < ActiveRecord::Base
  include ::ApiPageable
  api_per_page_num 20

  belongs_to :curriculum
  belongs_to :learning_report
  belongs_to :period
  belongs_to :student
  belongs_to :sub_unit

  scope :archives,          ->           { sents.where('sent_on < ?', Time.zone.today) }
  scope :currents,          ->           { sents.where(sent_on: Time.zone.today) }
  scope :include_videos,    ->           { includes(sub_unit: :videos) }
  scope :include_subject,   ->           { includes(sub_unit: { unit: :subject }) }
  scope :newest_first,      ->           { order('learnings.sent_on DESC') }
  scope :curriculum_order,  ->           { order('subjects.sort', 'units.schoolyear', 'units.sort', 'sub_units.sort', 'videos.filename') }
  scope :olders,            -> (sent_on) { where('learnings.sent_on < ?', sent_on) }
  scope :sents,             ->           { where(status: %i(sent pass failure reported)) }
  scope :units_sort,        -> (sort)    { where('units.sort >= ?', sort) if sort.present? }
  scope :sub_units_sort,    -> (sort)    { where('sub_units.sort >= ?', sort) if sort.present? }
  scope :include_video_subject, ->       { includes(sub_unit: { videos: %i(subject video_viewings_with_current_student) }) }

  state_machine :status, initial: :scheduled do
    before_transition on: :cancel do |record|
      record.box_id  = nil
      record.sent_on = nil
    end

    after_transition on: :cancel do |record|
      record.destroy if record.curriculum.blank? || (record.curriculum.present? && record.resended?)
    end

    event :to_sent do # 「今回の授業に設定」
      transition [:scheduled, :sent] => :sent
    end

    event :cancel do # 「今日は授業しなかった」
      transition [:scheduled, :sent] => :scheduled
    end

    event :failure do # 「後で復習」
      transition [:failure, :sent] => :failure
    end

    event :pass do # 「合格」
      transition [:pass, :sent] => :pass
    end

    state :scheduled do
      validates :box_id,      absence: true
      validates :sent_on,     absence: true
      validates :reported_at, absence: true
    end

    state :sent do
      validates :box_id,      presence: true
      validates :sent_on,     presence: true
      validates :reported_at, absence: true
    end

    state :pass do
      validates :box_id,      presence: true
      validates :sent_on,     presence: true
      validates :reported_at, presence: true

      def resend!
        record = dup
        record.update!(status: :sent, reported_at: nil)
        record
      end
    end

    state :failure do
      validates :box_id,      presence: true
      validates :sent_on,     presence: true
      validates :reported_at, presence: true

      def resend!
        record = dup
        record.update!(status: :sent, reported_at: nil)
        record
      end
    end
  end

  counter_culture :curriculum, column_name: lambda { |record|
    'total_count' if (record.scheduled? && !record.resended? && record.creation?) || !record.curriculum.nil?
  }

  counter_culture :curriculum, column_name: lambda { |record|
    'done_count' if (record.failure? || record.pass?) && !record.resended?
  }

  def resended?
    ::Learning.where.not(id: id)
              .exists?(student:    student,
                       sub_unit:   sub_unit,
                       curriculum: curriculum)
  end

  def creation?
    created_at == updated_at
  end
end
