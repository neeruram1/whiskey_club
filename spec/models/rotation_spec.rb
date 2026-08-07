require 'rails_helper'

RSpec.describe Rotation do
  describe '.members and .candidates' do
    it 'lists rotation members in order, candidates separately' do
      a = create(:user)
      b = create(:user)
      c = create(:user)
      described_class.add(a)
      described_class.add(b)

      expect(described_class.members).to eq([a, b])
      expect(described_class.candidates).to include(c)
      expect(described_class.candidates).not_to include(a)
    end
  end

  describe '.add' do
    it 'appends to the end with contiguous positions' do
      a = create(:user)
      b = create(:user)
      described_class.add(a)
      described_class.add(b)

      expect(a.reload.rotation_position).to eq(1)
      expect(b.reload.rotation_position).to eq(2)
    end

    it 'is idempotent' do
      a = create(:user)
      described_class.add(a)
      described_class.add(a)

      expect(User.in_rotation.count).to eq(1)
    end
  end

  describe '.remove' do
    it 'removes a member and closes the gap' do
      a = create(:user)
      b = create(:user)
      c = create(:user)
      [a, b, c].each { |u| described_class.add(u) }

      described_class.remove(b)

      expect(described_class.members).to eq([a, c])
      expect(c.reload.rotation_position).to eq(2)
    end
  end

  describe '.move' do
    it 'swaps a member one step up' do
      a = create(:user)
      b = create(:user)
      described_class.add(a)
      described_class.add(b)

      described_class.move(b, :up)

      expect(described_class.members).to eq([b, a])
    end

    it 'is a no-op at the top boundary' do
      a = create(:user)
      b = create(:user)
      described_class.add(a)
      described_class.add(b)

      described_class.move(a, :up)

      expect(described_class.members).to eq([a, b])
    end
  end

  describe '.next_guide' do
    it 'is nil for an empty rotation' do
      expect(described_class.next_guide).to be_nil
    end

    it 'is the first member when no tasting has a rotation guide' do
      a = create(:user)
      b = create(:user)
      described_class.add(a)
      described_class.add(b)

      expect(described_class.next_guide).to eq(a)
    end

    it 'is the member after the most recent tasting guide' do
      a = create(:user)
      b = create(:user)
      c = create(:user)
      [a, b, c].each { |u| described_class.add(u) }
      create(:meeting, bottle_bringer: b, date: 1.week.ago)

      expect(described_class.next_guide).to eq(c)
    end

    it 'wraps from the last member back to the first' do
      a = create(:user)
      b = create(:user)
      described_class.add(a)
      described_class.add(b)
      create(:meeting, bottle_bringer: b, date: 1.week.ago)

      expect(described_class.next_guide).to eq(a)
    end

    it 'falls back to the first member when the last guide was a guest' do
      a = create(:user)
      b = create(:user)
      described_class.add(a)
      described_class.add(b)
      create(:meeting, bottle_bringer: create(:user), date: 1.day.ago)

      expect(described_class.next_guide).to eq(a)
    end
  end
end
