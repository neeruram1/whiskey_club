module Stats
  # Member whose ratings sit closest to each bottle's club average (min 3 ratings).
  # Returns { user:, accuracy:, rating_count: } or nil.
  class GoldenNose
    MIN_RATINGS = 3

    def self.call
      users_with_ratings = User.joins(:ratings)
                               .group('users.id')
                               .having('COUNT(ratings.id) >= ?', MIN_RATINGS)

      accuracy_scores = users_with_ratings.filter_map do |user|
        user_ratings = Rating.includes(:bottle).where(user: user)

        differences = user_ratings.filter_map do |rating|
          bottle_avg = rating.bottle.average_rating
          (rating.score - bottle_avg).abs if bottle_avg
        end

        next if differences.empty?

        {
          user: user,
          accuracy: (5.0 - (differences.sum / differences.size.to_f)).round(2),
          rating_count: user_ratings.size
        }
      end

      accuracy_scores.max_by { |score| score[:accuracy] }
    end
  end
end
