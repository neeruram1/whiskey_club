class PublicController < ApplicationController
  def index
    @upcoming_meetings = Meeting.upcoming
    @past_meetings = Meeting.past_meetings
  end
end
