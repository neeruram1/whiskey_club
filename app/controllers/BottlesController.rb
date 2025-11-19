class BottlesController < ApplicationController
  before_action :set_meeting
  before_action :set_bottle, only: [:edit, :update, :destroy, :show]

  def new
    @bottle = @meeting.build_bottle
  end

  def create
    @bottle = @meeting.build_bottle(bottle_params)

    if @bottle.save!
      redirect_to meeting_path(@meeting), notice: "Bottle added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def show
  end

  def update
    if @bottle.update!(bottle_params)
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

  def set_meeting
    @meeting = Meeting.find(params[:meeting_id])
  end

  def set_bottle
    @bottle = @meeting.bottle
  end

  def bottle_params
    params.require(:bottle).permit(:name, :user_id, :distillery, :age, :final_score)
  end
end
