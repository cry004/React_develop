# == Schema Information
#
# Table name: subjects
#
#  id          :integer          not null, primary key
#  sort        :integer
#  school      :string
#  name        :string
#  type        :string
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  for_video   :boolean          default(TRUE)
#  ancestry    :string
#


class Subject < ActiveRecord::Base
  # 単一テーブル継承時にActiveRecordが使用する予約語typeとの競合を避けるため
  self.inheritance_column = :_type_disabled

  has_ancestry

  HIGHSCHOOL_EXAM_LIST = %w(standard high-level)
  UNIVERCITY_EXAM_LIST = %w(
    standard
    high-level
    basis-standard
    japanese_history_b-standard
    japanese_history_b-high-level
    world_history_b-standard
    world_history_b-high-level
    modern_language-standard
    modern_language-high-level
    classics-standard
    classics-high-level
    chinese_classics-standard
    chinese_classics-high-level
  )
  EXAM_LIST = HIGHSCHOOL_EXAM_LIST | UNIVERCITY_EXAM_LIST

  has_many :schoolbooks, dependent: :destroy
  has_many :sub_units,   dependent: :destroy, through: :units
  has_many :units,       dependent: :destroy
  has_many :videos,      dependent: :destroy

  scope :for_question_subject, ->(params) { where(school: params[:school], name: params[:name], type: "question").first }
  scope :for_video_subjects, ->(params) { where(school: params[:school], for_video: true).order("sort") }

  scope :for_non_fist_students, -> { where.not(type: EXAM_LIST) }
  scope :for_juku,              -> { where(type: 'learning') }
  scope :for_high_school_exam,  -> { where(school: 'c', type: HIGHSCHOOL_EXAM_LIST) }
  scope :for_university_exam,   -> { where(school: 'k', type: UNIVERCITY_EXAM_LIST) }
  scope :search_by_sub_subject, lambda { |sub_subject|
    school = sub_subject[0]
    name   = case
             when sub_subject.in?(C_SOCIOLOGIES)
               'sociology'
             when sub_subject.in?(K_SOCIOLOGIES)
               "#{sub_subject.split('_', 2)[1]}_b"
             when sub_subject.in?(EXCEPTION_SUB_SUBJECT_KEY)
               sub_subject.split('_', 2)[1].sub(/(_basis)?-(standard|high-level)/, '')
                                           .sub(/^(sociology|japanese)_/, '')
             else
               sub_subject.split('_', 3)[1]
             end
    where(school: school, name: name)
  }

  # additional subject (not for university_exam)
  # id 172.  japanese_classics
  # id 173.  japanese_chinese_classics
  scope :additional_subject, -> { where(id: [172, 173])}

  scope :available_subjects, lambda { |school = 'c', type = %w(regular exam)|
    if Version.instance.switching_flag
      Subject.where(school: school, type: type).where.not(name: 'japanese').order(:sort)
    else
      Subject.where(school: school, type: type, name: %w(english mathematics))
    end
  }

  scope :for_names_with_order, ->(names) {
    order = sanitize_sql_array(
      ["position((',' || name::text || ',') in ?)", names.join(',') + ',']
    )
    where(name: names).order(order)
  }

  COLOR_CODE = {
    "english"     => "#ff6b6b",
    "mathematics" => "#44c4ff",
    "science"     => "#49cf14",
    "geography"   => "#d5ca15",
    "history"     => "#ec37a6",
    "civics"      => "#f8801f",
    "japanese"    => "#b15ce5",

    "physics_basis"                 => "#7ce1d0",
    "physics_physics"               => "#2bdbbd",
    "mathematics_1"                 => "#89caf0",
    "mathematics_a"                 => "#3fb0f2",
    "mathematics_2"                 => "#0b9aee",
    "mathematics_b"                 => "#0487d2",
    "mathematics_3"                 => "#0079be",
    "biology_basis"                 => "#b17fc5",
    "biology_biology"               => "#8739a6",
    "english_grammar"               => "#f0a89e",
    "english_syntax"                => "#ee7363",
    "chemistry_basis"               => "#7fe7f3",
    "chemistry_chemistry"           => "#1ed9ef",
    "sociology_japanese_history_b"  => "#f4e93b",
    "sociology_world_history_b"     => "#f4cb3b",
    "sociology_geography_b"         => "#f49f3b"
  }

  SUBJECT_TYPE = {
    "regular" => "通常学習編",
    "exam"    => "テスト対策編"
  }

  SUBJECT_NAME = {
    'english'         => '英語',
    'mathematics'     => '数学',
    'japanese'        => '国語',
    'science'         => '理科',
    'geography'       => '地理',
    'history'         => '歴史',
    'civics'          => '公民',
    'social_studies'  => '社会',
    'physics'         => '物理',
    'chemistry'       => '化学',
    'biology'         => '生物',
    'sociology'       => '社会',
    'english_writing' => '英語（筆記）',
    'english_listening' => '英語（リスニング）',
    'mathematics_1a'  => '数学ⅠＡ',
    'mathematics_2b'  => '数学ⅡＢ'
  }

  SUBJECT_NAME_AND_TYPE = [
    "english_regular",
    "english_exam",
    "mathematics_regular",
    "mathematics_exam",
    "science_regular",
    "science_exam",
    "geography_regular",
    "geography_exam",
    "history_regular",
    "history_exam",
    "civics_regular",
    "civics_exam",
    "english_grammar",
    "english_syntax",
    "mathematics_1",
    "mathematics_a",
    "mathematics_2",
    "mathematics_b",
    "mathematics_3",
    "physics_basis",
    "physics_physics",
    "chemistry_basis",
    "chemistry_chemistry",
    "biology_basis",
    "biology_biology",
    "sociology_japanese_history_b",
    "sociology_world_history_b",
    "sociology_geography_b",
    "japanese_classics",
    "japanese_chinese_classics",
    "english_standard",
    "english_high-level",
    "mathematics_standard",
    "mathematics_high-level",
    "japanese_standard",
    "japanese_high-level",
    "science_standard",
    "science_high-level",
    "history_standard",
    "history_high-level",
    "civics_standard",
    "civics_high-level",
    "geography_standard",
    "geography_high-level",
    "english_writing_standard",
    "english_writing_high-level",
    "english_listening_standard",
    "english_listening_high-level",
    "mathematics_1a_standard",
    "mathematics_1a_high-level",
    "mathematics_2b_standard",
    "mathematics_2b_high-level",
    "physics_basis-standard",
    "physics_standard",
    "physics_high-level",
    "chemistry_basis-standard",
    "chemistry_standard",
    "chemistry_high-level",
    "biology_basis-standard",
    "biology_standard",
    "biology_high-level",
    "sociology_world_history_b-standard",
    "sociology_world_history_b-high-level",
    "sociology_japanese_history_b-standard",
    "sociology_japanese_history_b-high-level",
    "japanese_modern_language-standard",
    "japanese_modern_language-high-level",
    "japanese_classics-standard",
    "japanese_classics-high-level",
    "japanese_chinese_classics-standard",
    "japanese_chinese_classics-high-level"
  ]

  module V3
    SUBJECT_NAME = {
      's' => {
        'english' => '英語'
       },
      'c' => {
        'english'        => '英語',
        'mathematics'    => '数学',
        'japanese'       => '国語',
        'science'        => '理科',
        'geography'      => '地理',
        'history'        => '歴史',
        'civics'         => '公民',
        'social_studies' => '社会'
      },
      'k' => {
        'english'          => '英語',
        'mathematics'      => '数学',
        'physics'          => '物理',
        'chemistry'        => '化学',
        'biology'          => '生物',
        'sociology'        => '社会',
        'japanese_history' => '日本史',
        'world_history'    => '世界史',
        'geography'        => '地理',
        'japanese'         => '国語',
        'english_writing'  => '英語（筆記）',
        'english_listening'  => '英語（リスニング）',
        'mathematics_1a'   => '数学ⅠＡ',
        'mathematics_2b'   => '数学ⅡＢ'
      }
    }

    SUBJECT_NAME_AND_TYPE = {
      's' => %w(
        english
       ),
      'c' => %w(
        english_regular
        english_exam
        english_standard
        english_high-level
        mathematics_regular
        mathematics_exam
        mathematics_standard
        mathematics_high-level
        science_regular
        science_exam
        science_standard
        science_high-level
        geography_regular
        geography_exam
        geography_standard
        geography_high-level
        history_regular
        history_exam
        history_standard
        history_high-level
        civics_regular
        civics_exam
        civics_standard
        civics_high-level
        japanese_standard
        japanese_high-level
      ),
      'k' => %w(
        english_grammar
        english_syntax
        mathematics_1
        mathematics_a
        mathematics_2
        mathematics_b
        mathematics_3
        physics_basis
        physics_physics
        chemistry_basis
        chemistry_chemistry
        biology_basis
        biology_biology
        sociology_japanese_history_b
        sociology_world_history_b
        sociology_geography_b
        japanese_classics
        japanese_chinese_classics
        english_writing_standard
        english_writing_high-level
        english_listening_standard
        english_listening_high-level
        mathematics_1a_standard
        mathematics_1a_high-level
        mathematics_2b_standard
        mathematics_2b_high-level
        physics_basis-standard
        physics_standard
        physics_high-level
        chemistry_basis-standard
        chemistry_standard
        chemistry_high-level
        biology_basis-standard
        biology_standard
        biology_high-level
        sociology_world_history_b-standard
        sociology_world_history_b-high-level
        sociology_japanese_history_b-standard
        sociology_japanese_history_b-high-level
        japanese_modern_language-standard
        japanese_modern_language-high-level
        japanese_classics-standard
        japanese_classics-high-level
        japanese_chinese_classics-standard
        japanese_chinese_classics-high-level
      )
    }
    COLOR_CODE = {
      'c' => {
        'english'                => '#ff6b6b',
        'english_regular'        => '#ff6b6b',
        'english_exam'           => '#ff6b6b',
        'english_standard'       => '#ff6b6b',
        'english_high-level'     => '#ff6b6b',
        'mathematics'            => '#44c4ff',
        'mathematics_regular'    => '#44c4ff',
        'mathematics_exam'       => '#44c4ff',
        'mathematics_standard'   => '#44c4ff',
        'mathematics_high-level' => '#44c4ff',
        'science'                => '#49cf14',
        'science_regular'        => '#49cf14',
        'science_exam'           => '#49cf14',
        'science_standard'       => '#49cf14',
        'science_high-level'     => '#49cf14',
        'geography'              => '#d5ca15',
        'geography_regular'      => '#d5ca15',
        'geography_exam'         => '#d5ca15',
        'geography_standard'     => '#d5ca15',
        'geography_high-level'   => '#d5ca15',
        'history'                => '#ec37a6',
        'history_regular'        => '#ec37a6',
        'history_exam'           => '#ec37a6',
        'history_standard'       => '#ec37a6',
        'history_high-level'     => '#ec37a6',
        'civics'                 => '#f8801f',
        'civics_regular'         => '#f8801f',
        'civics_exam'            => '#f8801f',
        'civics_standard'        => '#f8801f',
        'civics_high-level'      => '#f8801f',
        'sociology'              => '#f8801f',
        'japanese'               => '#b15ce5',
        'japanese_standard'      => '#b15ce5',
        'japanese_high-level'    => '#b15ce5'
        },
      'k' => {
        'english'                                 => '#f0a89e',
        'mathematics'                             => '#89caf0',
        'physics'                                 => '#7ce1d0',
        'chemistry'                               => '#7fe7f3',
        'biology'                                 => '#94cc76',
        'sociology'                               => '#f66762',
        'japanese_history'                        => '#ea7abd',
        'japanese_history_b'                      => '#ea7abd',
        'world_history'                           => '#eaa47a',
        'world_history_b'                         => '#eaa47a',
        'geography'                               => '#e0de53',
        'geography_b'                             => '#e0de53',
        'japanese'                                => '#c898e6',
        'english_grammar'                         => '#f0a89e',
        'english_syntax'                          => '#ee7363',
        'mathematics_1'                           => '#89caf0',
        'mathematics_a'                           => '#3fb0f2',
        'mathematics_2'                           => '#0b9aee',
        'mathematics_b'                           => '#0487d2',
        'mathematics_3'                           => '#0079be',
        'physics_basis'                           => '#7ce1d0',
        'physics_physics'                         => '#2bdbbd',
        'chemistry_basis'                         => '#7fe7f3',
        'chemistry_chemistry'                     => '#1ed9ef',
        'biology_basis'                           => '#94cc76',
        'biology_biology'                         => '#68cc31',
        'sociology_japanese_history_b'            => '#ea7abd',
        'sociology_standard'                      => '#ea7abd',
        'sociology_world_history_b'               => '#eaa47a',
        'sociology_geography_b'                   => '#e0de53',
        'english_writing_standard'                => '#f0725f',
        'english_writing_high-level'              => '#f0725f',
        'english_listening_standard'              => '#f2a89c',
        'english_listening_high-level'            => '#f2a89c',
        'mathematics_1a_standard'                 => '#86c9f2',
        'mathematics_1a_high-level'               => '#86c9f2',
        'mathematics_2b_standard'                 => '#0098f1',
        'mathematics_2b_high-level'               => '#0098f1',
        'physics_basis-standard'                  => '#7ce1d0',
        'physics_standard'                        => '#7ce1d0',
        'physics_high-level'                      => '#7ce1d0',
        'chemistry_basis-standard'                => '#7fe7f3',
        'chemistry_standard'                      => '#1ed9ef',
        'chemistry_high-level'                    => '#1ed9ef',
        'biology_basis-standard'                  => '#94cc76',
        'biology_standard'                        => '#68cc31',
        'biology_high-level'                      => '#68cc31',
        'sociology_japanese_history_b-standard'   => '#ea7abd',
        'sociology_japanese_history_b-high-level' => '#ea7abd',
        'sociology_world_history_b-standard'      => '#eaa47a',
        'sociology_world_history_b-high-level'    => '#eaa47a',
        'japanese_modern_language-standard'       => '#68cc31',
        'japanese_modern_language-high-level'     => '#68cc31',
        'japanese_classics'                       => '#68cc31',
        'japanese_classics-standard'              => '#68cc31',
        'japanese_classics-high-level'            => '#68cc31',
        'japanese_chinese_classics'               => '#68cc31',
        'japanese_chinese_classics-standard'      => '#68cc31',
        'japanese_chinese_classics-high-level'    => '#68cc31',
        'classics'                                => '#68cc31',
        'classics-standard'                       => '#68cc31',
        'classics-high-level'                     => '#68cc31',
        'chinese_classics'                        => '#68cc31',
        'chinese_classics-standard'               => '#68cc31',
        'chinese_classics-high-level'             => '#68cc31',
      }
    }
    SUBJECT_TYPE = {
      'c' => {
        'regular'    => '通常学習編',
        'exam'       => 'テスト対策編',
        'question'   => '質問',
        'standard'   => '入試対策編 スタンダード',
        'high-level' => '入試対策編 ハイレベル'
      },
      'k' => {
        'english_grammar'              => '英語文法',
        'english_syntax'               => '英語構文',
        'mathematics_1'                => '数学Ⅰ',
        'mathematics_2'                => '数学Ⅱ',
        'mathematics_3'                => '数学Ⅲ',
        'mathematics_a'                => '数学A',
        'mathematics_b'                => '数学B',
        'chemistry_basis'              => '化学基礎',
        'chemistry_chemistry'          => '化学',
        'biology_basis'                => '生物基礎',
        'biology_biology'              => '生物',
        'physics_basis'                => '物理基礎',
        'physics_physics'              => '物理',
        'sociology_japanese_history_b' => '日本史B',
        'sociology_world_history_b'    => '世界史B',
        'sociology_geography_b'        => '地理B',
        'english_question'             => '英語',
        'mathematics_question'         => '数学',
        'japanese_question'            => '国語',
        'chemistry_question'           => '化学',
        'physics_question'             => '物理',
        'biology_question'             => '生物',
        'japanese_history_question'    => '日本史',
        'world_history_question'       => '世界史',
        'geography_question'           => '地理',
        'japanese_classics'            => '古文',
        'japanese_chinese_classics'    => '漢文',
        'english_writing_standard'                => 'センター 英語（筆記） スタンダード',
        'english_writing_high-level'              => 'センター 英語（筆記） ハイレベル',
        'english_listening_standard'              => 'センター 英語（リスニング） スタンダード',
        'english_listening_high-level'            => 'センター 英語（リスニング） ハイレベル',
        'mathematics_1a_standard'                 => 'センター 数学ⅠＡ スタンダード',
        'mathematics_1a_high-level'               => 'センター 数学ⅠＡ ハイレベル',
        'mathematics_2b_standard'                 => 'センター 数学ⅡＢ スタンダード',
        'mathematics_2b_high-level'               => 'センター 数学ⅡＢ ハイレベル',
        'physics_basis-standard'                  => 'センター 物理基礎 スタンダード',
        'physics_standard'                        => 'センター 物理 スタンダード',
        'physics_high-level'                      => 'センター 物理 ハイレベル',
        'chemistry_basis-standard'                => 'センター 化学基礎 スタンダード',
        'chemistry_standard'                      => 'センター 化学 スタンダード',
        'chemistry_high-level'                    => 'センター 化学 ハイレベル',
        'biology_basis-standard'                  => 'センター 生物基礎 スタンダード',
        'biology_standard'                        => 'センター 生物 スタンダード',
        'biology_high-level'                      => 'センター 生物 ハイレベル',
        'sociology_japanese_history_b-standard'   => 'センター 日本史Ｂ スタンダード',
        'sociology_japanese_history_b-high-level' => 'センター 日本史Ｂ ハイレベル',
        'sociology_world_history_b-standard'      => 'センター 世界史Ｂ スタンダード',
        'sociology_world_history_b-high-level'    => 'センター 世界史Ｂ ハイレベル',
        'japanese_modern_language-standard'       => 'センター 現代文 スタンダード',
        'japanese_modern_language-high-level'     => 'センター 現代文 ハイレベル',
        'japanese_classics-standard'              => 'センター 古文 スタンダード',
        'japanese_classics-high-level'            => 'センター 古文 ハイレベル',
        'japanese_chinese_classics-standard'      => 'センター 漢文 スタンダード',
        'japanese_chinese_classics-high-level'    => 'センター 漢文 ハイレベル',
      }
    }
  end

  # 下記のsubject_key は正規表現的にうまくマッピングできなかったので例外対応
  EXCEPTION_SUBJECT_KEY = %w(
    chemistry_basis-standard
    physics_basis-standard
    biology_basis-standard
    sociology_japanese_history_b-standard
    sociology_japanese_history_b-high-level
    sociology_world_history_b-standard
    sociology_world_history_b-high-level
    japanese_modern_language-standard
    japanese_modern_language-high-level
    japanese_classics
    japanese_classics-standard
    japanese_classics-high-level
    japanese_chinese_classics
    japanese_chinese_classics-standard
    japanese_chinese_classics-high-level
  )

  C_SOCIOLOGIES = %w(
    c_geography_standard
    c_geography_high-level
    c_history_standard
    c_history_high-level
    c_civics_standard
    c_civics_high-level
  )

  K_SOCIOLOGIES = %w(
    k_geography
    k_japanese_history
    k_world_history
  )

  EXCEPTION_SUB_SUBJECT_KEY = %w(
    k_chinese_classics
    k_physics_basis-standard
    k_chemistry_basis-standard
    k_biology_basis-standard
    k_sociology_japanese_history_b-standard
    k_sociology_japanese_history_b-high-level
    k_sociology_world_history_b-standard
    k_sociology_world_history_b-high-level
    k_japanese_modern_language-standard
    k_japanese_modern_language-high-level
    k_japanese_classics-standard
    k_japanese_classics-high-level
    k_japanese_chinese_classics-standard
    k_japanese_chinese_classics-high-level
  )

  def name_and_type
    name + "_" + type
  end
  alias full_name name_and_type

  def convert_for_question_subject
    subject_name = case
                   when name == 'sociology'
                     type.split('_')[0..-2].join('_')
                   when university_exam?
                     name.split('_')[0]
                   else
                     name
                   end
    Subject.find_by(name: subject_name, type: 'question', school: school)
  end

  def color_code
    COLOR_CODE[name]
  end

  def social_studies?
    ["geography", "history", "civics"].include?(name)
  end

  def exam?
    type == 'exam'
  end

  def high_school_exam?
    school == 'c' && type.in?(HIGHSCHOOL_EXAM_LIST)
  end

  def university_exam?
    school == 'k' && type.in?(UNIVERCITY_EXAM_LIST)
  end

  # @author hasumi
  # @since 20151026
  # ElasticsearchやLogglyに保存されているeventData.subjectから日本語の教科科目コース名を復元するもの
  # @todo 小学版や英検版が始まったら改修が必要
  def self.human_name(subject_type)
    V3::SUBJECT_TYPE['k'][subject_type].try(:+, '（高校）') ||
      V3::SUBJECT_NAME['c'][subject_type.split('_')[0]] + '_' + V3::SUBJECT_TYPE['c'][subject_type.split('_')[1]] + '（中学）'
  end

  # @author tamakoshi
  # @since 20160314
  def displayable_lesson_text_purchace_page?
    school == 'k' &&
      full_name.in?(Settings.displayable_lesson_text_purchace_page_subjects)
  end

  # define class methods
  class << self
    def get_name_and_type_by_subject_key(subject_key)
      if subject_key.end_with?('history_b-standard', 'history_b-high-level', 'language-standard', 'language-high-level', 'chinese_classics-standard', 'chinese_classics-high-level')
        names = subject_key.split('_')
        subject_name = names[0]
        subject_type = names[1..-1].join('_')
      elsif subject_key.end_with?('standard', 'high-level')
        names = subject_key.split('_')
        subject_name = names[0..-2].join('_')
        subject_type = names[-1]
      else
        subject_name, *tmp = subject_key.split('_')
        subject_type = tmp.join('_')
      end
      [subject_name, subject_type]
    end
  end
end
