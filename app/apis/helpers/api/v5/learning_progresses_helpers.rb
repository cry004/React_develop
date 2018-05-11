module API::V5::LearningProgressesHelpers
  SUBJECTS_ORDER = %w(english mathematics science social_studies japanese)

  def current_student_subject(student, school)
    schoolbook = current_schoolbook(student, school)
    school_subject = 
                case school
                when 'c' then middle_school_subject(schoolbook)
                when 'k' then high_school_subject(schoolbook)
                end
    order_subjects(school_subject)
  end

  def current_schoolbook(student, school)
    case school
    when 'c' then student.schoolbooks['info'].slice('c1', 'c2', 'c3')
    when 'k' then Settings.default_schoolbooks_settings.c.info.k.to_hash
    end
  end

  def middle_school_subject(schoolbooks)
    middle_subjects = schoolbooks.values
    units_subject   = units_subject_school(middle_subjects)
    units_subject.group_by do |subject|
      subject_name = subject[0].split('_')[0]
      subject_name.in?(%w(geography history civics social_studies)) ? 'social_studies' : subject_name
    end
  end

  def high_school_subject(schoolbook)
    units_subject = units_subject_school([schoolbook])
    units_subject.group_by do |subject|
      subject_name = subject[0].to_s.split('_')[0]
      if subject_name == 'sociology'
        'social_studies'
      elsif subject_name.in?(%w(physics chemistry biology))
        'science'
      else
        subject_name
      end
    end
  end

  def units_subject_school(school_subject)
    school_subject.flatten.inject{ |mem, hash| mem.merge(hash){ |subject_name, video_id, video_name| [video_id, video_name].flatten } }
  end

  def level_up(pre_level, current_level)
    pre_level != current_level
  end

  def order_subjects(subject_hash)
    SUBJECTS_ORDER.map { |index| [index, subject_hash[index]] }.to_h
  end

  # Find all the school books of student to calculate the total trophies
  def all_current_schoolbook_ids(student)
    middle_school_book_ids = all_middle_school_book_ids(student)
    high_school_book_ids   = all_high_school_book_ids(student)
    middle_school_book_ids + high_school_book_ids
  end

  # Remove school books is standard and high-level in c2 and c3, because it's duplicate units.
  # if student completed book in c1 then completed in c2 and c3
  def remove_middle_school_books_duplicate(all_schoolbooks)
    all_schoolbooks.slice('c2', 'c3').values.map{ |year| year.delete_if { |key,value| key.end_with?("standard", "high-level") } }
    all_schoolbooks.values.flat_map(&:values)
  end

  # Because school books in middle school perhaps be changed so I get all school books from student.schoolbooks
  def all_middle_school_book_ids(student)
    middle_school_books = current_schoolbook(student, 'c')
    middle_school_books = remove_middle_school_books_duplicate(middle_school_books)
    middle_school_books.flat_map(&:values)
  end

  # Because school books in middle school perhaps be changed so I get all school books from Settings.default_schoolbooks_settings
  def all_high_school_book_ids(student)
    high_school_books = current_schoolbook(student, 'k')
    high_school_books.values.flat_map{ |schoolbook| schoolbook.to_h.values }
  end

  def filter_video_ids(all_current_schoolbooks)
    all_units = all_current_schoolbooks.pluck(:units)
    all_units.flat_map { |schoolbook| schoolbook.map { |unit| unit['videos'].map{|video| video['id']}}}
  end

  def find_trophies_completed(student ,watched_videos)
    all_current_schoolbooks = Schoolbook.where(id: all_current_schoolbook_ids(student))
    units_video_ids    = filter_video_ids(all_current_schoolbooks)
    watched_video_ids  = watched_videos.pluck(:id)
    trophies_completed = 0
    units_video_ids.each do |unit|
      trophies_completed = trophies_completed.next if (watched_video_ids & unit).size == unit.size
    end
    trophies_completed
  end

  def remove_videos_free(videos, video_ids)
    videos.reject { |video| video_ids.exclude?(video.id) }
  end
end
