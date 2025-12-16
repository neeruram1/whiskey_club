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

    if @bottle.save
      redirect_to meeting_path(@meeting), notice: "Bottle added."
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

