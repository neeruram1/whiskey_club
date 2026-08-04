module Stats
  # Spirit guide (bottle bringer) whose bottles consistently score highest,
  # among those who have brought at least 2 bottles.
  # Returns { spirit_guide:, avg_score:, bottle_count: } or nil.
  class Tastemaker
    MIN_BOTTLES = 2

    def self.call
      User.joins(meetings: { bottles: :ratings })
          .select('users.*, AVG(ratings.score) as avg_score, COUNT(DISTINCT bottles.id) as bottle_count')
          .where('meetings.bottle_bringer_id = users.id')
          .group('users.id')
          .having('COUNT(DISTINCT bottles.id) >= ?', MIN_BOTTLES)
          .order(Arel.sql('avg_score DESC'))
          .first
          .then do |user|
            next nil unless user

            {
              spirit_guide: user,
              avg_score: user.avg_score.to_f.round(2),
              bottle_count: user.bottle_count
            }
          end
    end
  end
end
