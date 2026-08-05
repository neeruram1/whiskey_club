require 'rails_helper'

RSpec.describe Bottle, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:distillery) }
    it { should validate_presence_of(:user) }
    it { should validate_numericality_of(:age).only_integer.is_greater_than_or_equal_to(0).allow_nil }
    it { should validate_numericality_of(:final_score).is_greater_than(0).allow_nil }
  end

  describe 'associations' do
    it { should have_many(:ratings).dependent(:destroy) }
    it { should belong_to(:user) }
    it { should belong_to(:meeting) }
  end

  describe 'scopes' do
    let!(:revealed_bottle) { create(:bottle, :revealed) }
    let!(:unrevealed_bottle) { create(:bottle, :unrevealed) }
    let!(:past_bottle) { create(:bottle, meeting: create(:meeting, :past)) }
    let!(:future_bottle) { create(:bottle, meeting: create(:meeting, :upcoming)) }

    describe '.revealed' do
      it 'returns only revealed bottles' do
        expect(Bottle.revealed).to include(revealed_bottle)
        expect(Bottle.revealed).not_to include(unrevealed_bottle)
      end
    end

    describe '.unrevealed' do
      it 'returns only unrevealed bottles' do
        expect(Bottle.unrevealed).to include(unrevealed_bottle)
        expect(Bottle.unrevealed).not_to include(revealed_bottle)
      end
    end

    describe '.past_bottles' do
      it 'returns bottles from past meetings' do
        expect(Bottle.past_bottles).to include(past_bottle)
        expect(Bottle.past_bottles).not_to include(future_bottle)
      end

      it 'orders by date descending' do
        older_bottle = create(:bottle, meeting: create(:meeting, date: 2.weeks.ago))
        expect(Bottle.past_bottles.first).to eq(past_bottle)
        expect(Bottle.past_bottles.last).to eq(older_bottle)
      end
    end

    describe '.with_ratings' do
      let!(:bottle_with_ratings) { create(:bottle, :with_ratings) }
      let!(:bottle_without_ratings) { create(:bottle) }

      it 'returns only bottles that have ratings' do
        expect(Bottle.with_ratings).to include(bottle_with_ratings)
        expect(Bottle.with_ratings).not_to include(bottle_without_ratings)
      end
    end

    describe '.brought_by' do
      let(:member) { create(:user) }

      it 'includes bottles from meetings the member was the bringer for' do
        meeting = create(:meeting, bottle_bringer: member)
        bottle = create(:bottle, meeting: meeting, user: create(:user))

        expect(Bottle.brought_by(member)).to include(bottle)
      end

      it 'includes bottles the member added themselves' do
        bottle = create(:bottle, user: member)

        expect(Bottle.brought_by(member)).to include(bottle)
      end

      it 'excludes bottles the member had no part in' do
        bottle = create(:bottle, user: create(:user))

        expect(Bottle.brought_by(member)).not_to include(bottle)
      end

      it 'orders by meeting date descending' do
        older = create(:bottle, user: member, meeting: create(:meeting, date: 2.weeks.ago))
        newer = create(:bottle, user: member, meeting: create(:meeting, date: 1.day.ago))

        expect(Bottle.brought_by(member).to_a).to eq([newer, older])
      end
    end
  end

  describe '#reveal!' do
    let(:bottle) { create(:bottle, :unrevealed) }

    it 'sets revealed_at to current time' do
      freeze_time do
        bottle.reveal!
        expect(bottle.revealed_at).to eq(Time.current)
      end
    end

    it 'does not update if already revealed' do
      bottle.update(revealed_at: 1.day.ago)
      original_time = bottle.revealed_at
      bottle.reveal!
      expect(bottle.revealed_at).to eq(original_time)
    end
  end

  describe '#user_rating' do
    let(:bottle) { create(:bottle) }
    let(:user) { create(:user) }
    let!(:rating) { create(:rating, bottle: bottle, user: user) }

    it 'returns the rating for the specified user' do
      expect(bottle.user_rating(user)).to eq(rating)
    end

    it 'returns nil if user has not rated' do
      other_user = create(:user)
      expect(bottle.user_rating(other_user)).to be_nil
    end
  end

  describe '#rated_by?' do
    let(:bottle) { create(:bottle) }
    let(:user) { create(:user) }

    it 'returns true if user has rated the bottle' do
      create(:rating, bottle: bottle, user: user)
      expect(bottle.rated_by?(user)).to be true
    end

    it 'returns false if user has not rated the bottle' do
      expect(bottle.rated_by?(user)).to be false
    end
  end

  describe '#average_rating' do
    let(:bottle) { create(:bottle) }

    context 'with ratings' do
      before do
        create(:rating, bottle: bottle, score: 4)
        create(:rating, bottle: bottle, score: 5)
        create(:rating, bottle: bottle, score: 3)
      end

      it 'returns the average score' do
        expect(bottle.average_rating).to eq(4.0)
      end

      it 'memoizes the result' do
        first_call = bottle.average_rating
        expect(bottle).not_to receive(:ratings)
        second_call = bottle.average_rating
        expect(first_call).to eq(second_call)
      end
    end

    context 'without ratings' do
      it 'returns nil' do
        expect(bottle.average_rating).to be_nil
      end
    end
  end

  describe '#update_cached_average_rating' do
    let(:bottle) { create(:bottle) }

    it 'updates cached_average_rating column' do
      create(:rating, bottle: bottle, score: 4)
      create(:rating, bottle: bottle, score: 5)
      
      bottle.update_cached_average_rating
      expect(bottle.reload.read_attribute(:cached_average_rating)).to eq(4.5)
    end

    it 'clears memoized value' do
      bottle.instance_variable_set(:@average_rating, 3.0)
      bottle.update_cached_average_rating
      expect(bottle.instance_variable_get(:@average_rating)).to be_nil
    end
  end
end
