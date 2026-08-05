module Stats
  # Members with the lowest (hardest) and highest (easiest) average scores,
  # among those with at least 3 ratings.
  class RaterExtremes
    MIN_RATINGS = 3

    def self.hardest
      base.order(Arel.sql('avg_score ASC')).first
    end

    def self.easiest
      base.order(Arel.sql('avg_score DESC')).first
    end

    def self.base
      User.joins(:ratings)
          .select('users.*, AVG(ratings.score) as avg_score')
          .group('users.id')
          .having('COUNT(ratings.id) >= ?', MIN_RATINGS)
    end
    private_class_method :base
  end
end
