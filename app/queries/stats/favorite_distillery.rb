module Stats
  # The distillery represented by the most bottles, as a [distillery, count] pair (or nil).
  class FavoriteDistillery
    def self.call
      Bottle.where.not(distillery: [nil, ''])
            .group(:distillery)
            .count
            .max_by { |_distillery, count| count }
    end
  end
end
