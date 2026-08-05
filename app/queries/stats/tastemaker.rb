module Stats
  # Spirit guide whose bottles consistently score highest.
  #
  # Measured directly off the meetings a member was the bottle bringer for
  # (independent of whether they marked attendance), among members who have
  # brought at least MIN_BOTTLES distinct rated bottles.
  # Returns { spirit_guide:, avg_score:, bottle_count: } or nil.
  class Tastemaker
    MIN_BOTTLES = 2

    def self.call
      User.joins(guided_meetings: { bottles: :ratings })
          .select('users.*, AVG(ratings.score) as avg_score, COUNT(DISTINCT bottles.id) as bottle_count')
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
