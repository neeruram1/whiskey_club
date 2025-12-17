class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find(params[:id])
    @is_current_user = @user == current_user

    # Stats
    @ratings = @user.ratings.includes(bottle: :meeting).order(score: :desc, created_at: :desc)
    @ratings_count = @ratings.count
    @avg_rating = @ratings.average(:score)&.round(1)
    
    # Bottles brought (both spirit guide and flight night)
    @bottles_brought = Bottle.joins(:meeting)
                             .where('meetings.bottle_bringer_id = ? OR bottles.user_id = ?', @user.id, @user.id)
                             .includes(:meeting, :ratings)
                             .order('meetings.date DESC')
    @bottles_brought_count = @bottles_brought.count
    
    # Encore Pours
    @encore_pours = @user.wishlisted_bottles
                         .includes(:meeting, :ratings)
                         .order('bottle_wishlists.created_at DESC')
    
    # Attendance
    @meetings_attended = @user.meetings.where('date < ?', Date.current).count
    @total_past_meetings = Meeting.where('date < ?', Date.current).count
    @attendance_rate = @total_past_meetings > 0 ? ((@meetings_attended.to_f / @total_past_meetings) * 100).round : 0
    
    # Taste compatibility (if viewing someone else's profile)
    unless @is_current_user
      @compatibility = calculate_taste_compatibility(@user, current_user)
    end
  end

  private

  def calculate_taste_compatibility(user1, user2)
    # Find bottles both users have rated
    user1_ratings = Rating.where(user: user1).pluck(:bottle_id, :score).to_h
    user2_ratings = Rating.where(user: user2).pluck(:bottle_id, :score).to_h
    
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
end
