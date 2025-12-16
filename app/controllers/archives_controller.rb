# app/controllers/archives_controller.rb
class ArchivesController < ApplicationController
  def index
    @bottles  = Bottle.past_bottles.includes(:meeting)
    @meetings = Meeting.order(date: :desc).includes(:bottle_bringer)
  end
end
