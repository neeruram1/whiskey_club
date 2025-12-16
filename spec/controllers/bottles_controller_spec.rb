require 'rails_helper'

RSpec.describe BottlesController, type: :controller do
  let(:user) { create(:user) }
  let(:meeting) { create(:meeting) }
  
  before { sign_in user }

  describe 'GET #index' do
    let!(:past_bottles) { create_list(:bottle, 3, meeting: create(:meeting, :past)) }

    it 'returns success' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns past bottles' do
      get :index
      expect(assigns(:past_bottles)).to match_array(past_bottles)
    end
  end

  describe 'GET #new' do
    it 'returns success' do
      get :new, params: { meeting_id: meeting.id }
      expect(response).to be_successful
    end

    it 'builds a new bottle for the meeting' do
      get :new, params: { meeting_id: meeting.id }
      expect(assigns(:bottle)).to be_a_new(Bottle)
      expect(assigns(:bottle).meeting).to eq(meeting)
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        name: 'Lagavulin 16',
        distillery: 'Lagavulin',
        user_id: user.id,
        age: 16
      }
    end

    context 'with valid parameters' do
      it 'creates a new bottle' do
        expect {
          post :create, params: { meeting_id: meeting.id, bottle: valid_attributes }
        }.to change(Bottle, :count).by(1)
      end

      it 'associates bottle with meeting' do
        post :create, params: { meeting_id: meeting.id, bottle: valid_attributes }
        expect(Bottle.last.meeting).to eq(meeting)
      end

      it 'redirects to the meeting' do
        post :create, params: { meeting_id: meeting.id, bottle: valid_attributes }
        expect(response).to redirect_to(meeting_path(meeting))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a bottle' do
        expect {
          post :create, params: { meeting_id: meeting.id, bottle: { name: nil } }
        }.not_to change(Bottle, :count)
      end

      it 'returns unprocessable entity status' do
        post :create, params: { meeting_id: meeting.id, bottle: { name: nil } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when user_id is not provided' do
      it 'defaults to current_user' do
        attributes = valid_attributes.except(:user_id)
        post :create, params: { meeting_id: meeting.id, bottle: attributes }
        expect(Bottle.last.user).to eq(user)
      end
    end
  end



  describe 'GET #edit' do
    let(:bottle) { create(:bottle) }

    it 'returns success' do
      get :edit, params: { id: bottle.id }
      expect(response).to be_successful
    end
  end

  describe 'PATCH #update' do
    let(:bottle) { create(:bottle) }
    let(:new_name) { 'Ardbeg 10' }

    context 'with valid parameters' do
      it 'updates the bottle' do
        patch :update, params: { id: bottle.id, bottle: { name: new_name } }
        bottle.reload
        expect(bottle.name).to eq(new_name)
      end

      it 'redirects to the meeting' do
        patch :update, params: { id: bottle.id, bottle: { name: new_name } }
        expect(response).to redirect_to(meeting_path(bottle.meeting))
      end
    end

    context 'with invalid parameters' do
      it 'does not update the bottle' do
        original_name = bottle.name
        patch :update, params: { id: bottle.id, bottle: { name: nil } }
        bottle.reload
        expect(bottle.name).to eq(original_name)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:bottle) { create(:bottle) }
    let(:meeting) { bottle.meeting }

    it 'destroys the bottle' do
      expect {
        delete :destroy, params: { id: bottle.id }
      }.to change(Bottle, :count).by(-1)
    end

    it 'redirects to the meeting' do
      delete :destroy, params: { id: bottle.id }
      expect(response).to redirect_to(meeting_path(meeting))
    end
  end
end
