module Stats
  # Member whose ratings sit closest to the rest of the club's opinion.
  #
  # Each of a member's ratings is compared against the average of *other*
  # members' ratings for that same bottle (the member's own vote is excluded, so
  # rating a bottle nobody else rated earns no free "accuracy"). Members need at
  # least MIN_RATINGS ratings overall, and at least one rating that overlaps with
  # another member. Returns { user:, accuracy:, rating_count: } or nil.
  class GoldenNose
    MIN_RATINGS = 3

    def self.call
      rows = Rating.pluck(:user_id, :bottle_id, :score)
      by_bottle = rows.group_by { |_user_id, bottle_id, _score| bottle_id }

      best = rows.group_by { |user_id, _bottle_id, _score| user_id }
                 .filter_map { |user_id, user_rows| score_member(user_id, user_rows, by_bottle) }
                 .max_by { |entry| entry[:accuracy] }
      return nil unless best

      { user: User.find(best[:user_id]), accuracy: best[:accuracy], rating_count: best[:rating_count] }
    end

    # Average absolute distance between a member's ratings and the rest of the
    # club's average for the same bottle, as an accuracy score (5.0 = perfect).
    def self.score_member(user_id, user_rows, by_bottle)
      return if user_rows.size < MIN_RATINGS

      diffs = user_rows.filter_map do |_uid, bottle_id, score|
        others = by_bottle[bottle_id].reject { |other_uid, _b, _s| other_uid == user_id }
        next if others.empty?

        others_avg = others.sum { |_o, _b, s| s } / others.size.to_f
        (score - others_avg).abs
      end
      return if diffs.empty?

      { user_id: user_id, accuracy: (5.0 - (diffs.sum / diffs.size)).round(2), rating_count: user_rows.size }
    end
    private_class_method :score_member
  end
end
