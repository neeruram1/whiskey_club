class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :bottle

  validates :score, presence: true, inclusion: { in: 1..5 }
  validates :comment, length: { maximum: 500 }
end
