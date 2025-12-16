# app/controllers/archives_controller.rb
class ArchivesController < ApplicationController
  def index
    # Eager load associations and preload ratings to avoid N+1 queries
    # This now includes all bottles from flight nights too
    @bottles = Bottle.past_bottles
                     .includes(:meeting, :user, :ratings)
                     .preload(:ratings)
    
    # Preload user-specific ratings for current user
    @user_ratings = Rating.where(user: current_user, bottle_id: @bottles.map(&:id))
                          .index_by(&:bottle_id)
    
    # Track which bottles are unrated by current user
    rated_bottle_ids = @user_ratings.keys
    @unrated_bottle_ids = @bottles.map(&:id) - rated_bottle_ids
    
    @meetings = Meeting.order(date: :desc)
                       .includes(:bottle_bringer, bottles: :ratings)
  end
end
