class BottlesController < ApplicationController
  before_action :set_meeting_from_params, only: [:new, :create]
  before_action :set_bottle, only: [:edit, :update, :destroy, :show]
  before_action :set_meeting_from_bottle, only: [:edit, :update, :destroy, :show]

  def index
    @past_bottles = Bottle.past_bottles
  end

  def new
    @bottle = @meeting.bottles.build(user: current_user)
    render layout: !turbo_frame_request?
  end

  def create
    @bottle = @meeting.bottles.build(bottle_params)
    @bottle.user ||= current_user
    
    # Auto-reveal if meeting date has arrived
    if @meeting.date <= Date.current
      @bottle.revealed_at = Time.current
    end

    if @bottle.save
      redirect_to meeting_path(@meeting), notice: "Bottle added.", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    render layout: !turbo_frame_request?
  end
  
  def show
    # Ratings already loaded via set_bottle and eager loading
    @current_user_rating = current_user ? @bottle.ratings.find { |r| r.user_id == current_user.id } : nil
    @all_ratings = @bottle.ratings.sort_by { |r| [-r.score, r.created_at] }
    @is_unrated = current_user && @current_user_rating.nil?

    if params[:peek] == "1"
      render partial: "bottles/peek", locals: { bottle: @bottle }
    elsif params[:peek] == "0"
      render partial: "bottles/row", locals: { bottle: @bottle }
    end
  end

  def update
    if @bottle.update(bottle_params)
      respond_to do |format|
        format.turbo_stream { redirect_to meeting_path(@meeting), notice: "Bottle updated." }
        format.html { redirect_to meeting_path(@meeting), notice: "Bottle updated." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @bottle.destroy
    redirect_to meeting_path(@meeting), notice: "Bottle removed."
  end

  def reveal
    @bottle = Bottle.find(params[:id])
    @meeting = @bottle.meeting
    
    # Only spirit guide can reveal
    unless current_user.id == @meeting.bottle_bringer_id
      redirect_to meeting_path(@meeting), alert: "Only the spirit guide can reveal the bottle.", status: :see_other
      return
    end
    
    # Only reveal on or after meeting date
    unless @meeting.date <= Date.current
      redirect_to meeting_path(@meeting), alert: "Bottle can only be revealed on the meeting date.", status: :see_other
      return
    end
    
    @bottle.reveal!
    redirect_to meeting_path(@meeting), notice: "Bottle revealed! Everyone can now see and rate it.", status: :see_other
  end

  def toggle_wishlist
    @bottle = Bottle.find(params[:id])
    wishlist_item = current_user.bottle_wishlists.find_by(bottle: @bottle)
    
    if wishlist_item
      wishlist_item.destroy
      message = "Removed from wishlist"
    else
      current_user.bottle_wishlists.create(bottle: @bottle)
      message = "Added to wishlist"
    end
    
    redirect_back fallback_location: meeting_path(@bottle.meeting), notice: message, status: :see_other
  end

  private

  def set_meeting_from_params
    @meeting = Meeting.find(params[:meeting_id])
  end

  def set_meeting_from_bottle
    @meeting = @bottle.meeting
  end

  def set_bottle
    @bottle = Bottle.includes(:meeting, ratings: :user).find(params[:id])
  end

  def bottle_params
    params.require(:bottle).permit(:name, :user_id, :distillery, :age, :final_score, :bottle_type)
  end
end

