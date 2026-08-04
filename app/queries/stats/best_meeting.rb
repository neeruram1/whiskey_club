module Stats
  # Meeting whose bottles scored highest on average (min 3 ratings, tiebreaker: most ratings).
  class BestMeeting
    MIN_RATINGS = 3

    def self.call
      Meeting.joins(bottles: :ratings)
             .select('meetings.*, AVG(ratings.score) as avg_score, COUNT(ratings.id) as rating_count')
             .group('meetings.id')
             .having('COUNT(ratings.id) >= ?', MIN_RATINGS)
             .order(Arel.sql('avg_score DESC, rating_count DESC'))
             .first
    end
  end
end
