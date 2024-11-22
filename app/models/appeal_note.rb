# frozen_string_literal: true

# == Schema Information
#
# Table name: appeal_notes
#
#  id         :bigint(8)        not null, primary key
#  content    :text             not null
#  appeal_id  :bigint(8)        not null
#  account_id :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AppealNote < ApplicationRecord
  CONTENT_SIZE_LIMIT = 2_000

  belongs_to :account
  belongs_to :appeal, inverse_of: :notes, touch: true

  scope :chronological, -> { reorder(id: :asc) }

  validates :content, presence: true, length: { maximum: CONTENT_SIZE_LIMIT }
end