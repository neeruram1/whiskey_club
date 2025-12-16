require 'rails_helper'

RSpec.describe RatingsController, type: :controller do
  let(:user) { create(:user) }
  let(:bottle) { create(:bottle, :revealed) }
  
  before { sign_in user }

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        nose: 4,
        taste: 5,
        finish: 4,
        notes: 'Great peaty flavor'
      }
    end

    context 'with valid parameters' do
      it 'creates a new rating' do
        expect {
          post :create, params: { bottle_id: bottle.id, rating: valid_attributes }
        }.to change(Rating, :count).by(1)
      end

      it 'associates rating with current user and bottle' do
        post :create, params: { bottle_id: bottle.id, rating: valid_attributes }
        rating = Rating.last
        expect(rating.user).to eq(user)
        expect(rating.bottle).to eq(bottle)
      end

      it 'redirects to the bottle' do
        post :create, params: { bottle_id: bottle.id, rating: valid_attributes }
        expect(response).to redirect_to(bottle_path(bottle))
      end

      it 'sets success flash message' do
        post :create, params: { bottle_id: bottle.id, rating: valid_attributes }
        expect(flash[:notice]).to eq('Rating was successfully created.')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { nose: nil, taste: nil, finish: nil } }

      it 'does not create a rating' do
        expect {
          post :create, params: { bottle_id: bottle.id, rating: invalid_attributes }
        }.not_to change(Rating, :count)
      end

      it 'returns unprocessable entity status' do
        post :create, params: { bottle_id: bottle.id, rating: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when rating already exists for user and bottle' do
      before { create(:rating, user: user, bottle: bottle) }

      it 'does not create duplicate rating' do
        expect {
          post :create, params: { bottle_id: bottle.id, rating: valid_attributes }
        }.not_to change(Rating, :count)
      end
    end
  end

  describe 'GET #edit' do
    let(:rating) { create(:rating, user: user, bottle: bottle) }

    it 'returns success' do
      get :edit, params: { id: rating.id }
      expect(response).to be_successful
    end

    it 'assigns the rating' do
      get :edit, params: { id: rating.id }
      expect(assigns(:rating)).to eq(rating)
    end
  end

  describe 'PATCH #update' do
    let(:rating) { create(:rating, user: user, bottle: bottle, nose: 3) }
    let(:new_nose) { 5 }

    context 'with valid parameters' do
      it 'updates the rating' do
        patch :update, params: { id: rating.id, rating: { nose: new_nose } }
        rating.reload
        expect(rating.nose).to eq(new_nose)
      end

      it 'redirects to the bottle' do
        patch :update, params: { id: rating.id, rating: { nose: new_nose } }
        expect(response).to redirect_to(bottle_path(rating.bottle))
      end

      it 'sets success flash message' do
        patch :update, params: { id: rating.id, rating: { nose: new_nose } }
        expect(flash[:notice]).to eq('Rating was successfully updated.')
      end

      it 'updates bottle average rating' do
        original_avg = bottle.average_rating
        patch :update, params: { id: rating.id, rating: { nose: 5, taste: 5, finish: 5 } }
        bottle.reload
        expect(bottle.average_rating).to be > original_avg
      end
    end

    context 'with invalid parameters' do
      it 'does not update the rating' do
        original_nose = rating.nose
        patch :update, params: { id: rating.id, rating: { nose: nil } }
        rating.reload
        expect(rating.nose).to eq(original_nose)
      end

      it 'returns unprocessable entity status' do
        patch :update, params: { id: rating.id, rating: { nose: nil } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:rating) { create(:rating, user: user, bottle: bottle) }

    it 'destroys the rating' do
      expect {
        delete :destroy, params: { id: rating.id }
      }.to change(Rating, :count).by(-1)
    end

    it 'redirects to the bottle' do
      bottle = rating.bottle
      delete :destroy, params: { id: rating.id }
      expect(response).to redirect_to(bottle_path(bottle))
    end

    it 'sets success flash message' do
      delete :destroy, params: { id: rating.id }
      expect(flash[:notice]).to eq('Rating was successfully destroyed.')
    end

    it 'updates bottle average rating' do
      create(:rating, :excellent, bottle: bottle)
      original_avg = bottle.average_rating
      delete :destroy, params: { id: rating.id }
      bottle.reload
      expect(bottle.average_rating).not_to eq(original_avg)
    end
  end
end
