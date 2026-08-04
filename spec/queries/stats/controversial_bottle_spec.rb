require 'rails_helper'

RSpec.describe Stats::ControversialBottle do
  describe '.call' do
    it 'returns the bottle with the greatest rating variance (min 3 ratings)' do
      divisive = create(:bottle)
      agreed = create(:bottle)
      [0, 3, 5].each { |s| create(:rating, bottle: divisive, score: s) }
      [4, 4, 4].each { |s| create(:rating, bottle: agreed, score: s) }

      expect(described_class.call).to eq(divisive)
    end

    it 'ignores bottles with fewer than 3 ratings' do
      bottle = create(:bottle)
      2.times { |i| create(:rating, bottle: bottle, score: i) }

      expect(described_class.call).to be_nil
    end
  end
end
