class RatingsController < ApplicationController
  before_action :authenticate_user!

  def create
    @rating = Rating.find_or_initialize_by(
      user: current_user,
      bottle_id: rating_params[:bottle_id]
    )

    @rating.score = rating_params[:score]

    if @rating.save
      redirect_to meeting_path(@rating.bottle.meeting), notice: "Rating saved."
    else
      redirect_back fallback_location: root_path,
                    alert: @rating.errors.full_messages.to_sentence
    end
  end

  private

  def rating_params
    params.require(:rating).permit(:score, :bottle_id)
  end
end

