class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  has_many :ratings, dependent: :destroy
  has_many :bottles, dependent: :destroy
  has_many :meeting_attendees, dependent: :destroy
  has_many :meetings, through: :meeting_attendees
  has_many :guided_meetings, class_name: 'Meeting', foreign_key: :bottle_bringer_id,
                             inverse_of: :bottle_bringer, dependent: :nullify
  has_many :bottle_wishlists, dependent: :destroy
  has_many :wishlisted_bottles, through: :bottle_wishlists, source: :bottle

  # Members who are part of the spirit-guide rotation, in turn order.
  scope :in_rotation, -> { where.not(rotation_position: nil).order(:rotation_position) }
  scope :not_in_rotation, -> { where(rotation_position: nil).order(:first_name) }

  def full_name
    "#{first_name} #{last_name}"
  end

  # How many tastings this member has been the spirit guide for (including any
  # upcoming ones). Used to hype the guide on the tasting page.
  def times_guiding
    guided_meetings.count
  end

  # The average club rating across every bottle this member has poured. Returns
  # nil when none of their pours have been rated yet.
  def pours_average_score
    Rating.where(bottle: Bottle.brought_by(self)).average(:score)
  end

  def wishlist_includes?(bottle)
    bottle_wishlists.exists?(bottle: bottle)
  end
end
