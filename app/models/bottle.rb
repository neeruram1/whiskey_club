class Bottle < ApplicationRecord
  belongs_to :user
  belongs_to :meeting
  has_many :ratings, dependent: :destroy
  has_many :bottle_wishlists, dependent: :destroy
  has_many :wishlisters, through: :bottle_wishlists, source: :user

  validates :name, presence: true
  validates :distillery, presence: true
  validates :user, presence: true
  validates :age, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :final_score, numericality: { greater_than: 0 }, allow_nil: true

  scope :revealed, -> { where.not(revealed_at: nil) }
  scope :unrevealed, -> { where(revealed_at: nil) }
  scope :past_bottles, -> { joins(:meeting).where("meetings.date < ?", Date.current).order("meetings.date DESC") }
  scope :with_ratings, -> { joins(:ratings).distinct }

  # Cache ratings count
  after_save :update_cached_average_rating, if: -> { saved_change_to_attribute?(:id) }

  def reveal!
    update(revealed_at: Time.current) unless revealed_at
  end

  def user_rating(user)
    ratings.find_by(user: user)
  end

  def rated_by?(user)
    ratings.exists?(user: user)
  end

  def average_rating
    @average_rating ||= read_attribute(:cached_average_rating) || ratings.average(:score)
  end

  def update_cached_average_rating
    @average_rating = nil # Clear memoization
    avg = ratings.average(:score)
    current_cached = read_attribute(:cached_average_rating)
    update_column(:cached_average_rating, avg) if avg != current_cached
  end
end
