require 'rails_helper'

RSpec.describe RatingsController, type: :controller do
  let(:user) { create(:user) }
  let(:bottle) { create(:bottle, :revealed) }

  before { sign_in user }

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        bottle_id: bottle.id,
        score: 4,
        comment: 'Great peaty flavor'
      }
    end

    context 'with valid parameters' do
      it 'creates a new rating' do
        expect {
          post :create, params: { rating: valid_attributes }
        }.to change(Rating, :count).by(1)
      end

      it 'associates rating with current user and bottle' do
        post :create, params: { rating: valid_attributes }
        rating = Rating.last
        expect(rating.user).to eq(user)
        expect(rating.bottle).to eq(bottle)
      end

      it 'redirects to the bottle' do
        post :create, params: { rating: valid_attributes }
        expect(response).to redirect_to(bottle_path(bottle))
      end

      it 'sets success flash message' do
        post :create, params: { rating: valid_attributes }
        expect(flash[:notice]).to eq('Rating saved.')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { bottle_id: bottle.id, score: nil } }

      it 'does not create a rating' do
        expect {
          post :create, params: { rating: invalid_attributes }
        }.not_to change(Rating, :count)
      end
    end

    context 'when rating already exists for user and bottle' do
      before { create(:rating, user: user, bottle: bottle) }

      it 'does not create duplicate rating' do
        expect {
          post :create, params: { rating: valid_attributes }
        }.not_to change(Rating, :count)
      end
    end
  end

  describe 'PATCH #update' do
    let(:rating) { create(:rating, user: user, bottle: bottle, score: 3) }

    context 'with valid parameters' do
      it 'updates the rating' do
        patch :update, params: { id: rating.id, rating: { score: 5 } }
        rating.reload
        expect(rating.score).to eq(5)
      end

      it 'redirects to the bottle' do
        patch :update, params: { id: rating.id, rating: { score: 5 } }
        expect(response).to redirect_to(bottle_path(rating.bottle))
      end

      it 'sets success flash message' do
        patch :update, params: { id: rating.id, rating: { score: 5 } }
        expect(flash[:notice]).to eq('Rating updated.')
      end

      it 'updates bottle average rating' do
        original_avg = bottle.average_rating
        patch :update, params: { id: rating.id, rating: { score: 5 } }
        bottle.reload
        expect(bottle.average_rating).not_to eq(original_avg)
      end
    end
  end
end
