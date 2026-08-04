module Stats
  # Highest club-average bottle with at least 3 ratings (tiebreaker: most ratings).
  class TopBottle
    MIN_RATINGS = 3

    def self.call
      Bottle.joins(:ratings)
            .select('bottles.*, AVG(ratings.score) as avg_score, COUNT(ratings.id) as rating_count')
            .group('bottles.id')
            .having('COUNT(ratings.id) >= ?', MIN_RATINGS)
            .order(Arel.sql('avg_score DESC, rating_count DESC'))
            .first
    end
  end
end
