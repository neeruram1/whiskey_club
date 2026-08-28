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
      # Turbo needs 303 to follow the redirect as a page visit, not a stream.
      expect(response).to have_http_status(:see_other)
    end

    it 'removes a member from the rotation' do
      member = create(:user)
      Rotation.add(member)

      delete :remove, params: { user_id: member.id }

      expect(member.reload.rotation_position).to be_nil
      expect(response).to redirect_to(admin_rotation_path)
      # Turbo needs 303 to follow the redirect as a page visit, not a stream.
      expect(response).to have_http_status(:see_other)
    end

    it 'moves a member up in the order' do
      a = create(:user)
      b = create(:user)
      Rotation.add(a)
      Rotation.add(b)

      post :move, params: { user_id: b.id, direction: 'up' }

      expect(Rotation.members).to eq([b, a])
      expect(response).to redirect_to(admin_rotation_path)
      # Turbo needs 303 to follow the redirect as a page visit, not a stream.
      expect(response).to have_http_status(:see_other)
    end

    # Reordering never moves whoever is already on the calendar — they're locked
    # to their scheduled date — so the list marks that member.
    describe 'the scheduled-guide badge' do
      let(:scheduled) { create(:user) }
      let(:other) { create(:user) }

      it 'badges the member guiding the upcoming tasting' do
        Rotation.add(other)
        Rotation.add(scheduled)
        meeting = create(:meeting, bottle_bringer: scheduled, date: 5.days.from_now.to_date)

        get :index

        expect(assigns(:scheduled_guide_id)).to eq(scheduled.id)
        expect(response.body).to include("Guiding #{meeting.date.strftime('%b %-d')}")
        expect(response.body.scan('Guiding ').size).to eq(1)
      end

      it 'badges no one when nothing is on the calendar' do
        Rotation.add(other)

        get :index

        expect(assigns(:scheduled_guide_id)).to be_nil
        expect(response.body).not_to include('Guiding ')
      end
    end
  end
end
