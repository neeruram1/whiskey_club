require 'rails_helper'

RSpec.describe Admin::RotationController, type: :controller do
  render_views

  describe 'authorization' do
    context 'when signed in as a non-admin' do
      before { sign_in create(:user) }

      it 'redirects index to root with an alert' do
        get :index
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end

      it 'does not add anyone to the rotation' do
        member = create(:user)
        expect do
          post :add, params: { user_id: member.id }
        end.not_to(change { User.in_rotation.count })
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when not signed in' do
      it 'redirects to the login page' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  context 'when signed in as an admin' do
    let(:admin) { create(:user, :admin) }

    before { sign_in admin }

    it 'renders the rotation page' do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it 'adds a member to the rotation' do
      member = create(:user)
      expect do
        post :add, params: { user_id: member.id }
      end.to change { member.reload.rotation_position }.from(nil)
      expect(response).to redirect_to(admin_rotation_path)
    end

    it 'removes a member from the rotation' do
      member = create(:user)
      Rotation.add(member)

      delete :remove, params: { user_id: member.id }

      expect(member.reload.rotation_position).to be_nil
    end

    it 'moves a member up in the order' do
      a = create(:user)
      b = create(:user)
      Rotation.add(a)
      Rotation.add(b)

      post :move, params: { user_id: b.id, direction: 'up' }

      expect(Rotation.members).to eq([b, a])
    end
  end
end
