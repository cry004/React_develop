# == Schema Information
#
# Table name: post_messages
#
#  id                    :integer          not null, primary key
#  default_reply_message :string           default("質問ありがとうございました。返信をお待ちください。"), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#


class PostMessage < ActiveRecord::Base
  acts_as_singleton
end
