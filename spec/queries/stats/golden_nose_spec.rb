require 'rails_helper'

RSpec.describe Stats::GoldenNose do
  describe '.call' do
    it 'returns the member whose ratings sit closest to the club average' do
      accurate = create(:user)
      outlier = create(:user)
      bottles = create_list(:bottle, 3)

      bottles.each do |bottle|
        # Baseline consensus around 3, plus one accurate (near avg) and one outlier.
        2.times { create(:rating, bottle: bottle, score: 3) }
        create(:rating, bottle: bottle, user: accurate, score: 3)
        create(:rating, bottle: bottle, user: outlier, score: 0)
      end

      result = described_class.call
      expect(result[:user]).to eq(accurate)
      expect(result[:accuracy]).to be > 4.0
    end

    it 'returns nil when nobody has 3+ ratings' do
      create(:rating)
      expect(described_class.call).to be_nil
    end
  end
end
