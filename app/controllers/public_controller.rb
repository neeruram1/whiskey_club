class PublicController < ApplicationController
  def index
    @current_meeting = Meeting.current
  end
end
