# == Schema Information
#
# Table name: product_relations
#
#  id                    :integer          not null, primary key
#  product_id            :integer          not null
#  relational_product_id :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_product_relations_on_product_id                            (product_id)
#  index_product_relations_on_product_id_and_relational_product_id  (product_id,relational_product_id) UNIQUE
#  index_product_relations_on_relational_product_id                 (relational_product_id)
#


class ProductRelation < ActiveRecord::Base
  belongs_to :relational_product, class_name: "Product"
end
