module Stats
  # The distillery represented by the most bottles, as a [distillery, count] pair
  # (or nil). This is a popularity/frequency measure, not a rating-based one.
  class MostPouredDistillery
    def self.call
      Bottle.where.not(distillery: [nil, ''])
            .group(:distillery)
            .count
            .max_by { |_distillery, count| count }
    end
  end
end
