class MeetingsController < ApplicationController
  before_action :find_meeting, only: [:show, :edit, :update]

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

  private

  def meeting_params
    params.require(:meeting).permit(:bottle_bringer_id, :date)
  end

  def find_meeting
    @meeting = Meeting.find(params[:id])
  end
end
