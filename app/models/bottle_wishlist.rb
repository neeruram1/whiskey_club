class BottleWishlist < ApplicationRecord
  belongs_to :user
  belongs_to :bottle

  validates :user_id, uniqueness: { scope: :bottle_id }
end
