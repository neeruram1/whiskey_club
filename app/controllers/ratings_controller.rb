# app/controllers/ratings_controller.rb
class RatingsController < ApplicationController
  before_action :authenticate_user!

  def create
    bottle_id = rating_params[:bottle_id]
    score     = rating_params[:score]
    comment   = rating_params[:comment]

    rating = Rating.find_or_initialize_by(user: current_user, bottle_id: bottle_id)
    rating.score = score
    rating.comment = comment

    if rating.save
      redirect_back fallback_location: bottle_path(bottle_id), notice: "Rating saved."
    else
      redirect_back fallback_location: bottle_path(bottle_id), alert: rating.errors.full_messages.to_sentence
    end
  end

  def update
    rating = Rating.find(params[:id])
    
    unless rating.user == current_user
      redirect_back fallback_location: root_path, alert: "You can only update your own ratings."
      return
    end

    if rating.update(rating_params.except(:bottle_id))
      redirect_back fallback_location: bottle_path(rating.bottle_id), notice: "Rating updated."
    else
      redirect_back fallback_location: bottle_path(rating.bottle_id), alert: rating.errors.full_messages.to_sentence
    end
  end

  private

  def rating_params
    params.require(:rating).permit(:bottle_id, :score, :comment)
  end
end

