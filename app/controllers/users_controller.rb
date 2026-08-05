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
    @bottles_brought = Bottle.brought_by(@user).includes(:meeting, :ratings)
    @bottles_brought_count = @bottles_brought.count
    
    # Encore Pours
    @encore_pours = @user.wishlisted_bottles
                         .includes(:meeting, :ratings)
                         .order('bottle_wishlists.created_at DESC')
    
    # Attendance
    attendance = Attendance.new(@user)
    @meetings_attended = attendance.meetings_attended
    @total_past_meetings = attendance.total_past_meetings
    @attendance_rate = attendance.rate
    
    # Member since date (first meeting attended or first rating)
    first_meeting_date = @user.meetings.minimum(:date)
    first_rating_date = @user.ratings.joins(bottle: :meeting).minimum('meetings.date')
    @member_since = [first_meeting_date, first_rating_date].compact.min || @user.created_at
    
    # Taste compatibility (if viewing someone else's profile)
    unless @is_current_user
      @compatibility = Stats::TasteProfile.new(@user).compatibility_with(current_user)
    end
  end
end
