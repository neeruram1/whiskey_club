class PublicController < ApplicationController
  def index
    @next_meeting = Meeting.where("date >= ?", Date.current)
                           .order(date: :asc)
                           .includes(:bottle_bringer, bottles: [:ratings, :user])
                           .first

    # Ratings by current user with eager loading
    @my_ratings = Rating.includes(bottle: :meeting).where(user: current_user)
    @ratings_count = @my_ratings.count
    @avg_rating = @my_ratings.average(:score)&.round(1)

    # Top 3 highest rated bottles by user (use joins to avoid loading all ratings)
    @top_rated = Bottle.joins(:ratings)
                       .where(ratings: { user: current_user })
                       .select('bottles.*, ratings.score')
                       .order('ratings.score DESC')
                       .limit(3)

    # Bottles brought with eager loading (includes both spirit guide bottles and flight night bottles)
    @bottles_brought = Bottle.joins(:meeting)
                             .where('meetings.bottle_bringer_id = ? OR bottles.user_id = ?', current_user.id, current_user.id)
                             .includes(:meeting)
                             .order('meetings.date DESC')
    @bottles_brought_count = @bottles_brought.count

    # Find users with similar taste (based on shared bottle ratings)
    @taste_match = calculate_taste_similarity

    # Find which bottle bringer's bottles you rate highest
    @favorite_bringer = calculate_favorite_bringer
  end

  def stats
    # Overview stats
    @total_meetings = Meeting.count
    @total_bottles = Bottle.count
    @total_ratings = Rating.count
    @club_avg_rating = Rating.average(:score)&.round(2)

    # Top bottle (highest club average with at least 3 ratings, tiebreaker: most ratings)
    @top_bottle = Bottle.joins(:ratings)
                        .select('bottles.*, AVG(ratings.score) as avg_score, COUNT(ratings.id) as rating_count')
                        .group('bottles.id')
                        .having('COUNT(ratings.id) >= 3')
                        .order('avg_score DESC, rating_count DESC')
                        .first

    # Most controversial bottle (biggest variance in ratings)
    @controversial_bottle = Bottle.joins(:ratings)
                                  .select('bottles.*, 
                                          VARIANCE(ratings.score) as score_variance,
                                          AVG(ratings.score) as avg_score')
                                  .group('bottles.id')
                                  .having('COUNT(ratings.id) >= 3') # At least 3 ratings
                                  .order('score_variance DESC')
                                  .first

    # Golden Nose - ratings closest to club average
    @golden_nose = calculate_golden_nose

    # Tastemaker - spirit guide whose bottles score highest
    @tastemaker = calculate_tastemaker

    # Most prolific spirit guide
    @prolific_spirit_guide = User.joins(:meetings)
                        .select('users.*, COUNT(meetings.id) as meeting_count')
                        .group('users.id')
                        .order('meeting_count DESC')
                        .first

    # Hardest rater (lowest average score)
    @hardest_rater = User.joins(:ratings)
                        .select('users.*, AVG(ratings.score) as avg_score')
                        .group('users.id')
                        .having('COUNT(ratings.id) >= 3') # At least 3 ratings
                        .order('avg_score ASC')
                        .first

    # Easiest rater (highest average score)
    @easiest_rater = User.joins(:ratings)
                        .select('users.*, AVG(ratings.score) as avg_score')
                        .group('users.id')
                        .having('COUNT(ratings.id) >= 3') # At least 3 ratings
                        .order('avg_score DESC')
                        .first

    # Favorite distillery
    @favorite_distillery = Bottle.where.not(distillery: [nil, ''])
                                 .group(:distillery)
                                 .count
                                 .max_by { |_, count| count }

    # Best meeting (highest average rating for bottles at that meeting, min 3 ratings, tiebreaker: most ratings)
    @best_meeting = Meeting.joins(bottles: :ratings)
                           .select('meetings.*, AVG(ratings.score) as avg_score, COUNT(ratings.id) as rating_count')
                           .group('meetings.id')
                           .having('COUNT(ratings.id) >= 3')
                           .order('avg_score DESC, rating_count DESC')
                           .first
  end

  private

  def calculate_taste_similarity
    my_ratings = Rating.where(user: current_user).index_by(&:bottle_id)
    return nil if my_ratings.empty?

    # More efficient query: get all ratings for same bottles
    bottle_ids = my_ratings.keys
    other_ratings = Rating.where(bottle_id: bottle_ids)
                         .where.not(user_id: current_user.id)
                         .includes(:user)

    # Group by user and calculate similarity
    similarity_scores = other_ratings.group_by(&:user).map do |other_user, their_ratings|
      next if their_ratings.size < 2 # Minimum 2 shared bottles

      # Calculate average difference
      differences = their_ratings.map do |their_rating|
        my_rating = my_ratings[their_rating.bottle_id]
        (my_rating.score - their_rating.score).abs
      end

      avg_difference = differences.sum.to_f / differences.size
      
      {
        user: other_user,
        similarity: (5.0 - avg_difference).round(2),
        shared_bottles: their_ratings.size
      }
    end.compact

    similarity_scores.max_by { |s| s[:similarity] }
  end

  def calculate_favorite_bringer
    # Get all ratings by current user with bottle bringer info (excluding self)
    ratings_with_bringers = Rating.joins(bottle: :user)
                                   .where(user: current_user)
                                   .where.not('users.id': current_user.id)
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

  def calculate_golden_nose
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

  def calculate_tastemaker
    # Find spirit guide whose bottles consistently score highest
    # Note: Uses meeting.bottle_bringer for regular tastings
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
