class BottlesController < ApplicationController
  before_action :set_meeting_from_params, only: [:new, :create]
  before_action :set_bottle, only: [:edit, :update, :destroy, :show]
  before_action :set_meeting_from_bottle, only: [:edit, :update, :destroy, :show]

  def index
    @past_bottles = Bottle.past_bottles
  end

  def new
    @bottle = @meeting.build_bottle
  end

  def create
    @bottle = @meeting.build_bottle(bottle_params)

    if @bottle.save
      redirect_to meeting_path(@meeting), notice: "Bottle added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end
  
  def show
    @bottle = Bottle.includes(:meeting).find(params[:id])

    if params[:peek] == "1"
      render partial: "bottles/peek", locals: { bottle: @bottle }
    elsif params[:peek] == "0"
      render partial: "bottles/row", locals: { bottle: @bottle }
    end
  end

  def update
    if @bottle.update(bottle_params)
      redirect_to meeting_path(@meeting), notice: "Bottle updated."
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
    @bottle = Bottle.find(params[:id])
  end

  def bottle_params
    params.require(:bottle).permit(:name, :user_id, :distillery, :age, :final_score)
  end
end

