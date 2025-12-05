class MeetingsController < ApplicationController
  before_action :find_meeting, only: [:show, :edit, :update]
  before_action :find_rating, only: [:show]

  def new
    @meeting = Meeting.new
    @users = User.all
  end

  def create
    @meeting = Meeting.new(meeting_params)
    
    if @meeting.save
      redirect_to root_path, notice: 'Meeting scheduled successfully.'
    else
      @users = User.all
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @bottle = @meeting&.bottle
  end

  def edit
    @users = User.all
  end

  def update
    if @meeting.update(meeting_params)
      redirect_to meeting_path(@meeting), notice: 'Meeting updated successfully.'
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
    return if @meeting&.bottle&.ratings&.empty?
    @user_rating = @meeting&.bottle&.ratings&.find_by(user: current_user)&.score
  end


  private

  def meeting_params
    params.require(:meeting).permit(:bottle_bringer_id, :date)
  end

  def find_meeting
    @meeting = Meeting.find(params[:id])
  end
end
