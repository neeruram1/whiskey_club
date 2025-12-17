class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  has_many :ratings
  has_many :bottles
  has_many :meeting_attendees
  has_many :meetings, through: :meeting_attendees
  has_many :bottle_wishlists, dependent: :destroy
  has_many :wishlisted_bottles, through: :bottle_wishlists, source: :bottle

  def full_name
    "#{first_name} #{last_name}"
  end
  
  def wishlist_includes?(bottle)
    bottle_wishlists.exists?(bottle: bottle)
  end
end
