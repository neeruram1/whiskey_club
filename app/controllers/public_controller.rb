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

    # Attendance stats
    @meetings_attended = current_user.meetings.where('date < ?', Date.current).count
    @total_past_meetings = Meeting.where('date < ?', Date.current).count
    @attendance_rate = @total_past_meetings > 0 ? ((@meetings_attended.to_f / @total_past_meetings) * 100).round : 0

    # Bottles brought with eager loading (includes both spirit guide bottles and flight night bottles)
    @bottles_brought = Bottle.joins(:meeting)
                             .where('meetings.bottle_bringer_id = ? OR bottles.user_id = ?', current_user.id, current_user.id)
                             .includes(:meeting)
                             .order('meetings.date DESC')
    @bottles_brought_count = @bottles_brought.count

    # Find users with similar taste (based on shared bottle ratings)
    @taste_match = current_user.find_closest_match

    # Find which bottle bringer's bottles you rate highest
    @favorite_bringer = current_user.favorite_bringer
  end

  def wishlist
    @wishlisted_bottles = current_user.wishlisted_bottles
                                      .includes(:meeting, :user)
                                      .order(created_at: :desc)
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
    @golden_nose = User.golden_nose

    # Tastemaker - spirit guide whose bottles score highest
    @tastemaker = User.tastemaker

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
end
