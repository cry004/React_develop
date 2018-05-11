module JukuHelpers
  def current_chief
    env['api.endpoint'].instance_variable_get('@current_chief')
  end

  def destination
    case classroom_type
    when *Classroom::Fist::GYTI_KBN then FistStriker::Client::Destination::FIST
    when *Classroom::Plus::GYTI_KBN then FistStriker::Client::Destination::PLUS
    end
  end

  def to_do_learning_ids
    current_sub_units_ids = current_subject_sub_unit_ids
    learned = learned_sub_units.select{ |sub_unit| current_sub_units_ids.include? sub_unit }
    max_index_sub_units_ids = learned.map{ |sub_unit_id| current_sub_units_ids.index(sub_unit_id) }.max&.next.to_i
    current_sub_units_ids.from(max_index_sub_units_ids).take(3)
  end

  def classroom_type
    classroom = Classroom.find_by(id: current_chief.classroom_id)

    # NOTE:
    # If current_chief is from TryPlus, he always has classroom (classroom_id)
    # Obtain one from the array because any value is acceptable if it's "type" of FIST
    return Classroom::Fist::GYTI_KBN.first if classroom.blank?
    classroom.type
  end

  private

  def learned_sub_units
    @learnings.where.not(reported_at: nil)
                                    .map(&:sub_unit_id)
  end

  def current_subject_sub_unit_ids
    @units.flat_map(&:sub_unit_ids)
  end
end
