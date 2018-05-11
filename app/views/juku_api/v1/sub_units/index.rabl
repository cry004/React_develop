object false

node(:sub_subjects) { @sub_subjects }

child @units, object_root: false do
  attributes id:   :unit_id,
             name: :unit_name

  child :sub_units, object_root: false do
    attributes id:   :sub_unit_id,
               name: :sub_unit_name

    child :videos, object_root: false do
      attributes id:   :video_id,
                 name: :video_name
    end
  end
end
