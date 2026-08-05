require 'rails_helper'

RSpec.describe Stats::GoldenNose do
  describe '.call' do
    it "scores each member against other members' average, excluding their own vote" do
      accurate = create(:user)
      outlier = create(:user)
      bottles = create_list(:bottle, 3)

      bottles.each do |bottle|
        2.times { create(:rating, bottle: bottle, score: 3) } # baseline consensus
        create(:rating, bottle: bottle, user: accurate, score: 3)
        create(:rating, bottle: bottle, user: outlier, score: 0)
      end

      result = described_class.call
      # accurate vs others {3,3,0}=2.0 -> diff 1.0 -> accuracy 4.0
      # outlier  vs others {3,3,3}=3.0 -> diff 3.0 -> accuracy 2.0
      expect(result[:user]).to eq(accurate)
      expect(result[:accuracy]).to eq(4.0)
    end

    it 'does not reward rating bottles nobody else rated (no self-comparison)' do
      lone = create(:user)
      3.times { create(:rating, user: lone, bottle: create(:bottle), score: 5) }

      # Under the old self-including average this member scored a perfect 5.0;
      # with no overlapping raters they now have nothing to compare against.
      expect(described_class.call).to be_nil
    end

    it 'returns nil when nobody has 3+ ratings' do
      create(:rating)
      expect(described_class.call).to be_nil
    end
  end
end
