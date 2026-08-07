class PublicController < ApplicationController
  def index
    @next_meeting = Meeting.where("date >= ?", Time.zone.today)
                           .order(date: :asc)
                           .includes(:bottle_bringer, :attendees, bottles: [:ratings, :user])
                           .first

    # RSVP context for the next-tasting hero.
    if @next_meeting
      @next_attendees = @next_meeting.attendees.to_a
      @next_attending = @next_attendees.any? { |u| u.id == current_user.id }
      @next_awaiting = User.where.not(id: @next_attendees.map(&:id)).order(:first_name)
    end

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
    attendance = Attendance.new(current_user)
    @meetings_attended = attendance.meetings_attended
    @total_past_meetings = attendance.total_past_meetings
    @attendance_rate = attendance.rate

    # Bottles brought (spirit-guide bottles and flight-night bottles alike).
    @bottles_brought = Bottle.brought_by(current_user).includes(:meeting)
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
