class MeetingsController < ApplicationController
  def new
    @meeting = Meeting.new
  end

  def create
    @meeting = Meeting.new(meeting_params)
    asdfasdf
    if @meeting.save!
      redirect_to root_path, notice: 'Meeting scheduled successfully.'
    else
      render :new
    end
  end

  private

  def meeting_params
    params.require(:meeting).permit(:bottle_bringer_id, :date)
  end
end
