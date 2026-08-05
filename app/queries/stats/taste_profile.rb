module Stats
  # Per-member taste analytics: how a member's palate relates to others'.
  class TasteProfile
    def initialize(user)
      @user = user
    end

    # Similarity between this member and another, based on shared bottle ratings.
    # Returns { score:, shared_count: } or nil when there's no overlap.
    def compatibility_with(other_user)
      my_ratings    = ratings_by_bottle(@user)
      their_ratings = ratings_by_bottle(other_user)

      shared_bottles = my_ratings.keys & their_ratings.keys
      return nil if shared_bottles.empty?

      differences = shared_bottles.map do |bottle_id|
        (my_ratings[bottle_id] - their_ratings[bottle_id]).abs
      end

      avg_difference = differences.sum / differences.size.to_f
      {
        score: ((5.0 - avg_difference) / 5.0 * 100).round,
        shared_count: shared_bottles.size
      }
    end

    # The member whose palate is closest to this one (min 2 shared bottles).
    # Returns { user:, similarity:, shared_bottles: } or nil.
    def closest_match
      my_ratings = ratings_by_bottle(@user)
      return nil if my_ratings.size < 2

      other_ratings = Rating.where(bottle_id: my_ratings.keys)
                            .where.not(user_id: @user.id)
                            .includes(:user)

      similarity_scores = other_ratings.group_by(&:user).filter_map do |other_user, their_ratings|
        next if their_ratings.size < 2

        differences = their_ratings.map do |their_rating|
          (my_ratings[their_rating.bottle_id] - their_rating.score).abs
        end

        avg_difference = differences.sum.to_f / differences.size
        {
          user: other_user,
          similarity: (5.0 - avg_difference).round(2),
          shared_bottles: their_ratings.size
        }
      end

      similarity_scores.max_by { |score| [score[:similarity], score[:shared_bottles]] }
    end

    # The bottle bringer whose bottles this member rates highest (min 2 of their bottles).
    # Returns { bringer:, avg_score:, bottle_count: } or nil.
    def favorite_bringer
      result = Rating.joins(bottle: :user)
                     .where(user: @user)
                     .where.not('users.id': @user.id)
                     .select('users.id as bringer_id, users.first_name, users.last_name, ' \
                             'AVG(ratings.score) as avg_score, COUNT(ratings.id) as rating_count')
                     .group('users.id, users.first_name, users.last_name')
                     .having('COUNT(ratings.id) >= 2')
                     .order(Arel.sql('avg_score DESC'))
                     .first
      return nil unless result

      {
        bringer: User.find(result.bringer_id),
        avg_score: result.avg_score.to_f.round(1),
        bottle_count: result.rating_count
      }
    end

    private

    def ratings_by_bottle(user)
      Rating.where(user: user).pluck(:bottle_id, :score).to_h
    end
  end
end
