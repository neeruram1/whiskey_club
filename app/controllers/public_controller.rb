class PublicController < ApplicationController
  def index
    @next_meeting = Meeting.where("date >= ?", Time.zone.today)
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
    @meetings_attended = current_user.meetings.where('date < ?', Time.zone.today).count
    @total_past_meetings = Meeting.where('date < ?', Time.zone.today).count
    @attendance_rate = @total_past_meetings > 0 ? ((@meetings_attended.to_f / @total_past_meetings) * 100).round : 0

    # Bottles brought with eager loading (includes both spirit guide bottles and flight night bottles)
    @bottles_brought = Bottle.joins(:meeting)
                             .where('meetings.bottle_bringer_id = ? OR bottles.user_id = ?', current_user.id, current_user.id)
                             .includes(:meeting)
                             .order('meetings.date DESC')
    @bottles_brought_count = @bottles_brought.count

    # Taste analytics: closest-matching palate and favourite bottle bringer.
    taste_profile = Stats::TasteProfile.new(current_user)
    @taste_match = taste_profile.closest_match
    @favorite_bringer = taste_profile.favorite_bringer
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

    # Superlatives (each backed by a query object in app/queries/stats).
    @top_bottle = Stats::TopBottle.call
    @controversial_bottle = Stats::ControversialBottle.call
    @golden_nose = Stats::GoldenNose.call
    @tastemaker = Stats::Tastemaker.call
    @hardest_rater = Stats::RaterExtremes.hardest
    @easiest_rater = Stats::RaterExtremes.easiest
    @most_poured_distillery = Stats::MostPouredDistillery.call
    @best_meeting = Stats::BestMeeting.call
  end
end
