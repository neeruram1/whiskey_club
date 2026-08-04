require 'rails_helper'

RSpec.describe Stats::BestMeeting do
  describe '.call' do
    it 'returns the meeting whose bottles scored highest on average (min 3 ratings)' do
      best = create(:meeting)
      other = create(:meeting)
      best_bottle = create(:bottle, meeting: best)
      other_bottle = create(:bottle, meeting: other)
      3.times { create(:rating, bottle: best_bottle, score: 5) }
      3.times { create(:rating, bottle: other_bottle, score: 2) }

      expect(described_class.call).to eq(best)
    end

    it 'ignores meetings with fewer than 3 ratings' do
      meeting = create(:meeting)
      bottle = create(:bottle, meeting: meeting)
      2.times { create(:rating, bottle: bottle, score: 5) }

      expect(described_class.call).to be_nil
    end
  end
end
