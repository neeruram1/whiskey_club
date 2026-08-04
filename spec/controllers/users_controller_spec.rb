require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user) }

  before { sign_in user }

  describe 'GET #show' do
    it 'returns success for your own profile' do
      get :show, params: { id: user.id }
      expect(response).to be_successful
      expect(assigns(:is_current_user)).to be true
    end

    it 'assigns taste compatibility when viewing another member' do
      other = create(:user)
      bottle = create(:bottle)
      create(:rating, user: user, bottle: bottle, score: 4)
      create(:rating, user: other, bottle: bottle, score: 4)

      get :show, params: { id: other.id }

      expect(response).to be_successful
      expect(assigns(:compatibility)).to include(score: 100, shared_count: 1)
    end
  end
end
