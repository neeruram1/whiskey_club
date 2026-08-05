require 'rails_helper'

RSpec.describe Stats::TopBottle do
  describe '.call' do
    it 'returns the highest-average bottle with at least 3 ratings' do
      top = create(:bottle)
      also = create(:bottle)
      3.times { create(:rating, bottle: top, score: 5) }
      3.times { create(:rating, bottle: also, score: 2) }

      expect(described_class.call).to eq(top)
    end

    it 'ignores bottles with fewer than 3 ratings' do
      bottle = create(:bottle)
      2.times { create(:rating, bottle: bottle, score: 5) }

      expect(described_class.call).to be_nil
    end
  end
end
