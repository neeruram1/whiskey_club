require 'rails_helper'

RSpec.describe Stats::TasteProfile do
  let(:member) { create(:user) }

  describe '#compatibility_with' do
    it 'scores identical palates at 100%' do
      other = create(:user)
      bottle_a = create(:bottle)
      bottle_b = create(:bottle)
      create(:rating, user: member, bottle: bottle_a, score: 4)
      create(:rating, user: other, bottle: bottle_a, score: 4)
      create(:rating, user: member, bottle: bottle_b, score: 2)
      create(:rating, user: other, bottle: bottle_b, score: 2)

      result = described_class.new(member).compatibility_with(other)
      expect(result).to eq(score: 100, shared_count: 2)
    end

    it 'returns nil when there is no rating overlap' do
      other = create(:user)
      create(:rating, user: member, bottle: create(:bottle))
      create(:rating, user: other, bottle: create(:bottle))

      expect(described_class.new(member).compatibility_with(other)).to be_nil
    end
  end

  describe '#closest_match' do
    it 'finds the member with the most similar palate (min 2 shared bottles)' do
      twin = create(:user)
      bottle_a = create(:bottle)
      bottle_b = create(:bottle)
      create(:rating, user: member, bottle: bottle_a, score: 5)
      create(:rating, user: member, bottle: bottle_b, score: 3)
      create(:rating, user: twin, bottle: bottle_a, score: 5)
      create(:rating, user: twin, bottle: bottle_b, score: 3)

      expect(described_class.new(member).closest_match[:user]).to eq(twin)
    end

    it 'returns nil with fewer than 2 of my own ratings' do
      create(:rating, user: member, bottle: create(:bottle))
      expect(described_class.new(member).closest_match).to be_nil
    end
  end

  describe '#favorite_bringer' do
    it 'returns the bringer whose bottles this member rates highest (min 2)' do
      bringer = create(:user)
      bottle_a = create(:bottle, user: bringer)
      bottle_b = create(:bottle, user: bringer)
      create(:rating, user: member, bottle: bottle_a, score: 5)
      create(:rating, user: member, bottle: bottle_b, score: 5)

      result = described_class.new(member).favorite_bringer
      expect(result[:bringer]).to eq(bringer)
      expect(result[:bottle_count]).to eq(2)
    end
  end
end
