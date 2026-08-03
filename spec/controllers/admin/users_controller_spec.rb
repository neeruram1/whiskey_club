require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  render_views

  describe 'authorization' do
    context 'when signed in as a non-admin' do
      let(:user) { create(:user) }
      before { sign_in user }

      it 'redirects index to root with an alert' do
        get :index
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end

      it 'does not destroy a user' do
        victim = create(:user)
        expect {
          delete :destroy, params: { id: victim.id }
        }.not_to change(User, :count)
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

    describe 'GET #index' do
      it 'returns success and lists users' do
        create_list(:user, 2)
        get :index
        expect(response).to be_successful
        expect(assigns(:users)).to include(admin)
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the target user' do
        victim = create(:user)
        expect {
          delete :destroy, params: { id: victim.id }
        }.to change(User, :count).by(-1)
        expect(response).to redirect_to(admin_users_path)
        expect(flash[:notice]).to be_present
      end

      it 'refuses to delete your own account' do
        expect {
          delete :destroy, params: { id: admin.id }
        }.not_to change(User, :count)
        expect(flash[:alert]).to be_present
      end

      it 'cascades a user with ratings, bottles, and attendance without a foreign key error' do
        victim = create(:user)
        meeting = create(:meeting)
        bottle = create(:bottle, user: victim, meeting: meeting)
        rating = create(:rating, user: victim, bottle: bottle)
        # Rating#mark_meeting_attendance makes the rater an attendee
        expect(meeting.meeting_attendees.where(user: victim)).to exist

        expect {
          delete :destroy, params: { id: victim.id }
        }.to change(User, :count).by(-1)
        expect(Bottle.exists?(bottle.id)).to be false
        expect(Rating.exists?(rating.id)).to be false
        expect(MeetingAttendee.where(user_id: victim.id)).not_to exist
      end

      it 'nullifies bottle_bringer on meetings the deleted user hosted' do
        victim = create(:user)
        meeting = create(:meeting, bottle_bringer: victim)

        delete :destroy, params: { id: victim.id }

        expect(meeting.reload.bottle_bringer_id).to be_nil
      end
    end
  end
end
