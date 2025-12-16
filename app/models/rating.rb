class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :bottle

  validates :score, presence: true, inclusion: { in: 0..5 }
  validates :comment, length: { maximum: 500 }
  validates :bottle_id, uniqueness: { scope: :user_id }
end
