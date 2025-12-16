module BottlesHelper
  # Get user rating efficiently from preloaded hash
  def user_rating_for(bottle, user, preloaded_ratings = nil)
    if preloaded_ratings
      preloaded_ratings[bottle.id]&.score
    else
      bottle.user_rating(user)&.score
    end
  end

  # Get average rating efficiently (uses cached column)
  def average_rating_for(bottle)
    bottle.average_rating
  end

  # Format rating display
  def format_rating(rating)
    rating ? number_with_precision(rating, precision: 1) : "—"
  end
end
