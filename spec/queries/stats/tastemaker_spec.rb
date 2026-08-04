require 'rails_helper'

RSpec.describe Stats::Tastemaker do
  describe '.call' do
    it 'returns the bringer whose bottles score highest, with 2+ bottles brought' do
      guide = create(:user)
      meeting = create(:meeting, bottle_bringer: guide)
      # The stat joins meetings *through* attendance, so the bringer must attend.
      create(:meeting_attendee, user: guide, meeting: meeting)
      bottle_a = create(:bottle, meeting: meeting, user: guide)
      bottle_b = create(:bottle, meeting: meeting, user: guide)
      create(:rating, bottle: bottle_a, score: 5)
      create(:rating, bottle: bottle_b, score: 5)

      result = described_class.call
      expect(result[:spirit_guide]).to eq(guide)
      expect(result[:bottle_count]).to eq(2)
      expect(result[:avg_score]).to eq(5.0)
    end

    it 'returns nil when no bringer has brought at least 2 rated bottles' do
      guide = create(:user)
      meeting = create(:meeting, bottle_bringer: guide)
      bottle = create(:bottle, meeting: meeting, user: guide)
      create(:rating, bottle: bottle, score: 4)

      expect(described_class.call).to be_nil
    end
  end
end
