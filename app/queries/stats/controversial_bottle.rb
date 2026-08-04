module Stats
  # Bottle with the biggest variance in ratings (min 3 ratings).
  class ControversialBottle
    MIN_RATINGS = 3

    def self.call
      Bottle.joins(:ratings)
            .select('bottles.*, VARIANCE(ratings.score) as score_variance, AVG(ratings.score) as avg_score')
            .group('bottles.id')
            .having('COUNT(ratings.id) >= ?', MIN_RATINGS)
            .order(Arel.sql('score_variance DESC'))
            .first
    end
  end
end
