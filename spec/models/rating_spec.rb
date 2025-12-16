require 'rails_helper'

RSpec.describe Rating, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:score) }
    it { should validate_inclusion_of(:score).in_range(0..5) }
    it { should validate_length_of(:comment).is_at_most(500) }
    
    describe 'uniqueness' do
      let(:user) { create(:user) }
      let(:bottle) { create(:bottle) }
      
      before { create(:rating, user: user, bottle: bottle) }
      
      it 'validates uniqueness of bottle_id scoped to user_id' do
        duplicate_rating = build(:rating, user: user, bottle: bottle)
        expect(duplicate_rating).not_to be_valid
        expect(duplicate_rating.errors[:bottle_id]).to be_present
      end
      
      it 'allows same bottle rated by different users' do
        other_user = create(:user)
        rating = build(:rating, user: other_user, bottle: bottle)
        expect(rating).to be_valid
      end
    end
  end

  describe 'associations' do
    it { should belong_to(:bottle).counter_cache(true) }
    it { should belong_to(:user) }
  end

  describe 'callbacks' do
    let(:bottle) { create(:bottle) }
    let(:rating) { create(:rating, bottle: bottle, score: 4) }

    describe 'after_save' do
      it 'updates bottle average rating when created' do
        expect(bottle).to receive(:update_cached_average_rating)
        rating
      end

      it 'updates bottle average rating when updated' do
        rating
        expect(bottle).to receive(:update_cached_average_rating)
        rating.update(score: 5)
      end
    end

    describe 'after_destroy' do
      it 'updates bottle average rating when destroyed' do
        rating
        expect(bottle).to receive(:update_cached_average_rating)
        rating.destroy
      end
    end
  end
end
