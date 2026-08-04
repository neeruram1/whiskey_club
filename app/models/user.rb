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
  has_many :bottle_wishlists, dependent: :destroy
  has_many :wishlisted_bottles, through: :bottle_wishlists, source: :bottle

  def full_name
    "#{first_name} #{last_name}"
  end
  
  def wishlist_includes?(bottle)
    bottle_wishlists.exists?(bottle: bottle)
  end

  # Instance methods for compatibility and stats
  
  def taste_compatibility_with(other_user)
    # Find bottles both users have rated
    user1_ratings = Rating.where(user: self).pluck(:bottle_id, :score).to_h
    user2_ratings = Rating.where(user: other_user).pluck(:bottle_id, :score).to_h
    
    shared_bottles = user1_ratings.keys & user2_ratings.keys
    return nil if shared_bottles.empty?
    
    # Calculate average difference
    differences = shared_bottles.map do |bottle_id|
      (user1_ratings[bottle_id] - user2_ratings[bottle_id]).abs
    end
    
    avg_difference = differences.sum / differences.size.to_f
    similarity_score = ((5.0 - avg_difference) / 5.0 * 100).round
    
    {
      score: similarity_score,
      shared_count: shared_bottles.size
    }
  end

  def find_closest_match
    # Get all my ratings as a hash
    my_ratings = Rating.where(user: self).pluck(:bottle_id, :score).to_h
    return nil if my_ratings.size < 2

    # Get all ratings for same bottles from other users
    bottle_ids = my_ratings.keys
    other_ratings = Rating.where(bottle_id: bottle_ids)
                         .where.not(user_id: self.id)
                         .includes(:user)

    # Group by user and calculate similarity
    similarity_scores = other_ratings.group_by(&:user).map do |other_user, their_ratings|
      next if their_ratings.size < 2 # Minimum 2 shared bottles

      # Calculate average difference
      differences = their_ratings.map do |their_rating|
        my_rating = my_ratings[their_rating.bottle_id]
        (my_rating - their_rating.score).abs
      end

      avg_difference = differences.sum.to_f / differences.size
      
      {
        user: other_user,
        similarity: (5.0 - avg_difference).round(2),
        shared_bottles: their_ratings.size
      }
    end.compact

    # Sort by similarity first, then by shared_bottles as tiebreaker
    similarity_scores.max_by { |s| [s[:similarity], s[:shared_bottles]] }
  end

  def favorite_bringer
    # Get all ratings by this user with bottle bringer info (excluding self)
    ratings_with_bringers = Rating.joins(bottle: :user)
                                   .where(user: self)
                                   .where.not('users.id': self.id)
                                   .select('users.id as bringer_id, 
                                           users.first_name, 
                                           users.last_name, 
                                           AVG(ratings.score) as avg_score,
                                           COUNT(ratings.id) as rating_count')
                                   .group('users.id, users.first_name, users.last_name')
                                   .having('COUNT(ratings.id) >= 2') # At least 2 bottles
                                   .order('avg_score DESC')
                                   .first

    return nil unless ratings_with_bringers

    {
      bringer: User.find(ratings_with_bringers.bringer_id),
      avg_score: ratings_with_bringers.avg_score.to_f.round(1),
      bottle_count: ratings_with_bringers.rating_count
    }
  end

  # Class methods for club-wide stats
  
  def self.golden_nose
    # Find user whose ratings are closest to club averages
    users_with_ratings = User.joins(:ratings)
                            .group('users.id')
                            .having('COUNT(ratings.id) >= 3')
    
    accuracy_scores = users_with_ratings.map do |user|
      user_ratings = Rating.includes(:bottle).where(user: user)
      
      # Calculate average difference from bottle averages
      differences = user_ratings.filter_map do |rating|
        bottle_avg = rating.bottle.average_rating
        (rating.score - bottle_avg).abs if bottle_avg
      end
      
      next if differences.empty?
      
      {
        user: user,
        accuracy: (5.0 - (differences.sum / differences.size.to_f)).round(2),
        rating_count: user_ratings.size
      }
    end.compact
    
    accuracy_scores.max_by { |s| s[:accuracy] }
  end

  def self.tastemaker
    # Find spirit guide whose bottles consistently score highest
    User.joins(meetings: { bottles: :ratings })
        .select('users.*, 
                AVG(ratings.score) as avg_score,
                COUNT(DISTINCT bottles.id) as bottle_count')
        .where('meetings.bottle_bringer_id = users.id')
        .group('users.id')
        .having('COUNT(DISTINCT bottles.id) >= 2')
        .order('avg_score DESC')
        .first
        .then do |user|
          next nil unless user
          {
            spirit_guide: user,
            avg_score: user.avg_score.to_f.round(2),
            bottle_count: user.bottle_count
          }
        end
  end
end
