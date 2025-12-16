class PublicController < ApplicationController
  def index
    @next_meeting = Meeting.where("date >= ?", Date.current).order(date: :asc).includes(:bottle_bringer, :bottle).first

    # Ratings by current user
    @my_ratings = Rating.includes(:bottle).where(user: current_user)
    @ratings_count = @my_ratings.count
    @avg_rating = @my_ratings.average(:score)&.round(2)

    # Top 3 highest rated bottles by user
    @top_rated = @my_ratings
      .order(score: :desc)
      .limit(3)
      .map(&:bottle)
      .compact

    # Bottles brought (assumes meeting has bottle + bottle_bringer_id)
    # If your association is different, adjust this query.
    @bottles_brought = Bottle.joins(:meeting).where(meetings: { bottle_bringer_id: current_user.id }).includes(:meeting)
    @bottles_brought_count = @bottles_brought.count
  end

end
