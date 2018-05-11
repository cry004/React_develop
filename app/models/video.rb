# == Schema Information
#
# Table name: videos
#
#  id                                     :integer          not null, primary key
#  id_contents                            :string
#  name                                   :string
#  duration                               :integer
#  chapters                               :json
#  created_at                             :datetime         not null
#  updated_at                             :datetime         not null
#  schoolyear                             :string
#  subject_id                             :integer
#  thumbnail_url                          :string
#  checktest                              :string
#  filename                               :string
#  subname                                :string
#  duplicated                             :boolean          default(FALSE)
#  duplicated_count_num                   :integer
#  double_speed_video_id_contents         :string
#  registration_token                     :string
#  registration_token_at                  :datetime
#  replace_video_id_contents              :string
#  replace_double_speed_video_id_contents :string
#  lesson_text                            :json
#  view_count                             :integer          default(0), not null
#
# Indexes
#
#  index_videos_on_subject_id  (subject_id)
#


class Video < ActiveRecord::Base
  include ApplicationHelper

  attr_accessor :recommend_type, :count_of_viewed
  class_attribute :current_student_id

  belongs_to :subject
  has_one :video_breadcrumb_title_image
  has_one :video_title_image
  has_one :video_subtitle_image
  has_one :video_youtube_video, dependent: :destroy
  has_one :youtube_video, through: :video_youtube_video, dependent: :destroy
  has_one :sub_unit_video
  has_one :sub_unit, through: :sub_unit_video
  has_many :stars, dependent: :destroy
  has_many :completes, dependent: :destroy
  has_many :incomprehensibles, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :completables, dependent: :destroy
  has_many :thumbnails, dependent: :destroy
  has_many :video_relations, foreign_key: "video_id", dependent: :destroy
  has_many :relational_videos, through: :video_relations, source: :relational_video
  has_many :teacher_recommendation_videos, dependent: :destroy
  has_many :video_viewings, dependent: :destroy
  has_many :video_tags, -> { uniq }, dependent: :destroy
  has_many :video_worksheets
  has_many :worksheets, through: :video_worksheets

  has_one :video_worksheet

  has_one :ensyu_answer_worksheet, -> { where(category: :ensyu, type: :answer) },
                                   through: :video_worksheet,
                                   source:  :worksheet

  has_one :syutoku_answer_worksheet, -> { where(category: :syutoku, type: :answer) },
                                     through: :video_worksheet,
                                     source:  :worksheet

  # Please define Video.current_student_id before using it
  has_many :video_viewings_with_current_student, -> { where(video_viewings: { student_id: Video.current_student_id, watched: true }) }, class_name: VideoViewing.name, foreign_key: :video_id
  has_many :stars_with_current_student, -> { where(stars: { student_id: Video.current_student_id}) }, class_name: Star.name, foreign_key: :video_id
  validate :validate_lesson_text

  SchoolbookCompanyMap = {
    "学校図書" => "GT",
    "開隆堂" => "KR",
    "教育出版" => "KS",
    "光村図書" => "MT",
    "三省堂" => "SS",
    "東京書籍" => "TS"
  }

  scope :search_sent_learnings, lambda { |agreement_id|
    includes(sub_unit: :learnings)
      .where(learnings: { agreement_id: agreement_id, status: :sent })
  }

  scope :sum_duration, -> { take&.subject&.high_school_exam? ? count * 30.minutes : sum(:duration) }
  scope :includes_videos, -> { includes(%i(subject sub_unit video_viewings_with_current_student)) }
  scope :by_schoolyear, -> (schoolyear){ where('schoolyear LIKE ? ', "#{schoolyear}%") if schoolyear.present? }
  scope :watched_videos, -> { where(video_viewings: { watched: true }).uniq }
  # @author tamakoshi
  # @since 20150209
  # 動画一覧をunitsにある順番通りに戻す
  def self.sort_by_units_order(videos, video_ids)
    video_ids.map do |id|
      videos.select {|video|video.id == id }.first
    end
  end

  delegate :youtube_id,  to: :youtube_video, allow_nil: true
  delegate :description, to: :youtube_video, allow_nil: true
  delegate :url, to: :ensyu_answer_worksheet, allow_nil: true, prefix: :ensyu_answer_pdf
  delegate :url, to: :syutoku_answer_worksheet, allow_nil: true, prefix: :syutoku_answer_pdf

  def subtitle
    subject.exam? ? subname : sub_unit&.name
  end

  def chapters_with_incomprehensibles(current_student)
    positions = chapters.map{|chap|chap["position"]} << duration
    incomprehensibles_positions = current_student.questions.unscope(where: :state).where(video_id: id).sort{|a, b|a.position <=> b.position}.map do |question|
      {
        "duration" => Duration.new(:seconds => question.position).format("%M:%S"),
        "position" => question.position,
        "thumbnail_url" => nil,
        "question_state" => nil,
        "question_id" => question.id
      }
    end
    chapters.map.with_index do |chap, index|
      chap.merge({ "incomprehensibles" => incomprehensibles_positions.select { |inco|inco["position"] >= chap["position"] && inco["position"] < positions[index + 1] } })
    end
  end

  def next_videos(schoolbook)
    next_video_ids = schoolbook.next_video_ids(self.id)
    videos = Video.includes(:stars, :completes).where(id: next_video_ids)
    Video.sort_by_units_order(videos, next_video_ids)
  end

  def previous_videos(schoolbook)
    previous_video_ids = schoolbook.previous_video_ids(self.id)
    videos = Video.includes(:stars, :completes).where(id: previous_video_ids)
    Video.sort_by_units_order(videos, previous_video_ids)
  end

  def next_videos_schoolbook(schoolbook)
    next_video_ids = schoolbook.next_video_ids(self.id)
    videos = Video.where(id: next_video_ids).includes_videos
    Video.sort_by_units_order(videos, next_video_ids)
  end

  def previous_videos_schoolbook(schoolbook)
    previous_video_ids = schoolbook.previous_video_ids(self.id)
    videos = Video.where(id: previous_video_ids).includes_videos
    Video.sort_by_units_order(videos, previous_video_ids)
  end

  def duplicated_videos
    Video.where(filename: filename).select {|video| video.id != id }
  end

  def chapter_num_of_incomprehensible(position)
    chapters_with_index.find { |hash| hash[:range].include_with_range?(position.to_i) }
                       .try(:[], :index)
  end

  def chapters_with_index
    set_nums_block = lambda do |nums, index|
      if nums[1].to_i == duration
        range = (nums[0].to_i)..(nums[1].to_i)
      else
        range = (nums[0].to_i)...(nums[1].to_i)
      end
      { index: index, range: range }
    end

    chapters.map { |chap| chap['position'] }
            .uniq.compact.sort
            .push(duration).each_cons(2).with_index(1)
            .map(&set_nums_block)
  end

  def answer_url
    checktest.gsub('.pdf', '_ans.pdf')
  end

  def checktest_answer_displayable?
    !subject.high_school_exam? && !subject.university_exam?
  end

  def lesson_text_url
    return if lesson_text.blank?
    lesson_text['url']
  end

  def lesson_text_answer_url
    return if lesson_text.blank?
    lesson_text_url.gsub('.pdf', '_ans.pdf')
  end

  def lesson_text_image_url
    lesson_text_url&.sub('.pdf', '.jpg')
  end

  def lesson_text_answer_image_url
    lesson_text_url&.sub('.pdf', '_ans.jpg')
  end

  def practice_filename
    filename.gsub('.mp4', '_practice.pdf')
  end

  def practice_url
    return nil if schoolyear == 'k' && !subject.university_exam? # TODO: Remove this line on 2017/09/01
    if schoolyear == 'k' && subject.university_exam?
      lesson_text_url
    else
      Settings.practice_base_url + file_dir + practice_filename
    end
  end

  def practice_answer_url
    return nil if schoolyear == 'k' && !subject.university_exam? # TODO: Remove this line on 2017/09/01
    if schoolyear == 'k' && subject.university_exam?
      lesson_text_answer_url
    else
      practice_url.sub('.pdf', '_ans.pdf')
    end
  end

  def incomprehensible_thumbnail_url(position)
    round_off_position_time = round_off(position)
    incomprehensible_thumbnail_url = thumbnails.select { |thubnail| thubnail.position == round_off_position_time }.first.try(:resource_url)
    unless incomprehensible_thumbnail_url
      id_video_thumbnail, url = Millvi.create_thumbnail_at_time(id_contents, round_off_position_time)
      return Thumbnail.create(id_video_thumbnail: id_video_thumbnail, resource_url: url, video: self, position: round_off_position_time, width: 1280, height: 720).try(:resource_url)
    else
      return incomprehensible_thumbnail_url
    end
  end

  def notebook_filename
    filename.gsub('.mp4', '_note_ans.pdf')
  end

  def file_dir
    subject_name_and_type = subject.name_and_type
    case schoolyear
      when /\Ac\d*\z/
        generate_file_dir_from(subject_name_and_type)
      # 高校版の教師に渡すPDFは、_ansがつく。
      when 'k'
        "#{schoolyear}/#{subject_name_and_type}/"
      end
  end

  # @author tamakoshi
  # @since 20150711
  def notebook_url
    Settings.notebook_base_url + file_dir + notebook_filename
  end

  # titleimageが組版されたか
  def video_title_image_typesetted?
    video_title_image.try(:typesetting_flag)
  end

  # subtitleimageが組版されたか
  def video_subtitle_image_typesetted?
    video_subtitle_image.try(:typesetting_flag)
  end

  # breadcrumbs_titleimageが組版されたか
  def video_breadcrumb_title_image_typesetted?
    video_breadcrumb_title_image.try(:typesetting_flag)
  end

  def set_registration_token(token = nil)
    token.nil? ? generate_token(:registration_token) : (self.registration_token = token)
    self.registration_token_at = Time.now
    save!
  end

  def subject_name
    self.subject.full_name
  end

  def update_replace_id_contents(filename, id_contents)
    column = filename.match(/\Adouble_speed_/) ? :replace_double_speed_video_id_contents : :replace_video_id_contents
    self[column] = id_contents
    save!
  end

  def change_id_contents(filename, id_contents)
    update_replace_id_contents(filename, id_contents)
    if self.replace_double_speed_video_id_contents.present? && self.replace_video_id_contents.present?
      # 新しいサムネイルの取得
      thumbnail_url = Millvi.get_video_thumbnails(self.replace_video_id_contents).select { |thumb| thumb["id_video_thumbnail"] == "3" }.first["url"]
      # replace_video_id_contentsとreplace_video_id_contentsカラムの両方が更新された場合に初めてid_contentsとdouble_speed_video_id_contentsを入れ替える。
      update_attributes!(
        replace_video_id_contents: nil,
        replace_double_speed_video_id_contents: nil,
        registration_token: nil,
        registration_token_at: nil,
        id_contents: self.replace_video_id_contents,
        double_speed_video_id_contents: self.replace_double_speed_video_id_contents,
        thumbnail_url: thumbnail_url
      )
      # サムネイル画像の変更。
      self.reload
      replace_thumnails
    end
  end

  # @author tamakoshi
  # @since 20151026
  # 動画の科目が社会であった場合, callと表示する
  def schoolyear_for_eventlog
    if self.schoolyear.first == "c" && self.subject.social_studies?
      "call"
    else
      self.schoolyear
    end
  end

  def replace_thumnails
    positions = (0..self.duration).select {|num| (num % 5) == 0 }
    positions.each do |position|
      id_video_thumbnail, thumbnail_url = Millvi.create_thumbnail_at_time(self.id_contents, position)
      thumb = Thumbnail.find_by(video: self, position: position)
      if thumb
        thumb.update_attributes(resource_url: thumbnail_url, id_video_thumbnail: id_video_thumbnail)
      else
        Thumbnail.create!(video: self, position: position, resource_url: thumbnail_url, id_video_thumbnail: id_video_thumbnail, height: 720, width: 1280)
      end
    end
  end

  # @author tamakoshi
  # @since 20151215
  # lesson_textカラムが適切なjsonのノードを保持しているかどうかのバリデーション
  def validate_lesson_text
    return true unless self.lesson_text.present?
    # keyのチェック
    unless %w(url range).all? { |key| self.lesson_text.key? key } && %w(start end).all? { |key| self.lesson_text["range"].key? key }
      errors.add(:lesson_text, " is Invalid key")
      return false
    end

    # valueのチェック
    unless self.lesson_text["url"].is_a?(String) && self.lesson_text["range"]["start"].is_a?(Integer) && self.lesson_text["range"]["end"].is_a?(Integer)
      errors.add(:lesson_text, " is Invalid value")
      return false
    end
  end

  def textset_filename
    filename.sub('.mp4', '_textset.pdf')
  end

  def textset_url
    "#{Settings.textset_base_url}#{schoolyear}/#{subject_name}/#{textset_filename}"
  end

  def kaisetu_web_url
    return unless CurriculumElement.exists?(video_id: id, content_type: 'point')
    "#{Settings.hostname.parent}/videos/#{id}/curriculum_elements"
  end

  private

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64(64)
    end while  Video.exists?(column => self[column])
  end

  def generate_file_dir_from(subject_name_and_type)
    if subject_name_and_type == 'english_exam'
      company = URI.parse(checktest.sub(Settings.checktest_base_url, '')).path.split('/')[2]
      "#{schoolyear}/english_exam/#{company}/"
    elsif subject.social_studies?
      "call/#{subject_name_and_type}/"
    else
      "#{schoolyear}/#{subject_name_and_type}/"
    end
  end
end
