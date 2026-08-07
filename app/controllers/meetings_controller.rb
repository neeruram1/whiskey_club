class MeetingsController < ApplicationController
  before_action :find_meeting, only: [:show, :edit, :update]
  before_action :find_rating, only: [:show]

  def index
    @meetings = Meeting.includes(:bottle_bringer, bottles: :ratings)
                       .order(date: :desc)
    
    # Track which bottles user has rated - optimized to avoid N+1
    bottle_ids = @meetings.flat_map { |m| m.bottles.map(&:id) }.compact
    @user_ratings = Rating.where(user: current_user, bottle_id: bottle_ids)
                          .index_by(&:bottle_id)
  end

  def new
    @meeting = Meeting.new
    @users = User.all
    render layout: !turbo_frame_request?
  end

  def create
    @meeting = Meeting.new(meeting_params)
    
    if @meeting.save
      MeetingNotifier.scheduled(@meeting, except: current_user)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to meeting_path(@meeting), notice: 'Meeting scheduled successfully.' }
      end
    else
      @users = User.all
      render :new, status: :unprocessable_entity, layout: !turbo_frame_request?
    end
  end

  def show
    @bottle = @meeting&.primary_bottle
    @attendees = @meeting.attendees.includes(:ratings)
    @user_is_attending = current_user && @meeting.attendees.exists?(id: current_user.id)
    
    # Calculate meeting stats and load ratings
    if @bottle.present?
      @current_user_rating = current_user ? @bottle.ratings.find { |r| r.user_id == current_user.id } : nil
      @all_ratings = @bottle.ratings.includes(:user).order(score: :desc, created_at: :desc)
      @meeting_avg_rating = @bottle.ratings.average(:score)&.round(1)
      @total_ratings = @bottle.ratings.count
    end
  end

  def toggle_attendance
    @meeting = Meeting.find(params[:id])
    attendance = @meeting.meeting_attendees.find_by(user: current_user)
    
    if attendance
      attendance.destroy
      message = "Marked as not attending"
    else
      @meeting.meeting_attendees.create!(user: current_user)
      message = "Marked as attending"
    end
    
    redirect_back fallback_location: meeting_path(@meeting), notice: message, status: :see_other
  end

  def edit
    @users = User.all
    render layout: !turbo_frame_request?
  end

  def update
    if @meeting.update(meeting_params)
      respond_to do |format|
        format.turbo_stream { redirect_to meeting_path(@meeting), notice: 'Meeting updated successfully.' }
        format.html { redirect_to meeting_path(@meeting), notice: 'Meeting updated successfully.' }
      end
    else
      @users = User.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @meeting = Meeting.find(params[:id])
    @meeting.destroy
    redirect_to root_path, alert: 'Meeting deleted successfully.'
  end

  def find_rating
    return unless @meeting&.primary_bottle&.ratings&.any?

    @user_rating = @meeting.primary_bottle.ratings.find { |r| r.user_id == current_user.id }&.score
  end


  private

  def meeting_params
    params.require(:meeting).permit(:bottle_bringer_id, :date, :is_flight, :notes)
  end

  def find_meeting
    @meeting = Meeting.includes({ bottles: { ratings: :user } }, :bottle_bringer).find(params[:id])
  end
end
