class Bottle < ApplicationRecord
  belongs_to :user
  belongs_to :meeting
  has_many :ratings, dependent: :destroy

  validates :name, presence: true
  validates :distillery, presence: true
  validates :age, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :final_score, numericality: { greater_than: 0 }, allow_nil: true

  scope :revealed, -> { where.not(revealed_at: nil) }
  scope :unrevealed, -> { where(revealed_at: nil) }

  def reveal!
    update(revealed_at: Time.current) unless revealed_at
  end
end
