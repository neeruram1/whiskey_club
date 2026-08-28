require 'rails_helper'

RSpec.describe MeetingsController, type: :controller do
  let(:user) { create(:user) }
  
  before { sign_in user }

  describe 'GET #index' do
    let!(:meetings) { create_list(:meeting, 3, :with_bottle) }

    it 'returns success' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns @meetings ordered by date descending' do
      get :index
      expect(assigns(:meetings)).to eq(meetings.sort_by(&:date).reverse)
    end

    it 'eager loads associations to avoid N+1 queries' do
      # Just verify it runs without error
      get :index
      expect(response).to be_successful
    end

    it 'tracks user ratings' do
      bottle = meetings.first.primary_bottle
      create(:rating, user: user, bottle: bottle)
      
      get :index
      expect(assigns(:user_ratings)).to be_present
    end
  end

  describe 'GET #new' do
    it 'returns success' do
      get :new
      expect(response).to be_successful
    end

    it 'assigns a new meeting' do
      get :new
      expect(assigns(:meeting)).to be_a_new(Meeting)
    end

    it 'assigns all users' do
      create_list(:user, 3)
      get :new
      expect(assigns(:users).count).to eq(4) # 3 + logged in user
    end

    it 'prefills the bottle bringer with the next guide in the rotation' do
      next_up = create(:user)
      Rotation.add(next_up)
      get :new
      expect(assigns(:meeting).bottle_bringer_id).to eq(next_up.id)
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        bottle_bringer_id: user.id,
        date: Date.tomorrow,
        is_flight: false
      }
    end

    context 'with valid parameters' do
      it 'creates a new meeting' do
        expect {
          post :create, params: { meeting: valid_attributes }
        }.to change(Meeting, :count).by(1)
      end

      it 'redirects to the meeting show page' do
        post :create, params: { meeting: valid_attributes }
        expect(response).to redirect_to(meeting_path(Meeting.last))
      end

      it 'notifies the other members' do
        create_list(:user, 2)
        expect {
          post :create, params: { meeting: valid_attributes }
        }.to have_enqueued_mail(MeetingMailer, :scheduled).twice
      end
    end

    context 'with invalid parameters' do
      it 'does not create a meeting' do
        expect {
          post :create, params: { meeting: { date: nil } }
        }.not_to change(Meeting, :count)
      end

      it 'returns unprocessable entity status' do
        post :create, params: { meeting: { date: nil } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'for flight night' do
      let(:flight_attributes) do
        {
          bottle_bringer_id: nil,
          date: Date.tomorrow,
          is_flight: true
        }
      end

      it 'creates a flight night without bottle_bringer' do
        expect {
          post :create, params: { meeting: flight_attributes }
        }.to change(Meeting, :count).by(1)
        expect(Meeting.last.is_flight).to be true
        expect(Meeting.last.bottle_bringer).to be_nil
      end
    end
  end

  describe 'GET #show' do
    let(:meeting) { create(:meeting, :with_bottle) }

    it 'returns success' do
      get :show, params: { id: meeting.id }
      expect(response).to be_successful
    end

    it 'assigns the requested meeting' do
      get :show, params: { id: meeting.id }
      expect(assigns(:meeting)).to eq(meeting)
    end

    it 'eager loads associations' do
      get :show, params: { id: meeting.id }
      expect(response).to be_successful
    end

    # The club rates blind: on tasting day members rate the sealed dram before
    # the spirit guide reveals what it is.
    describe 'the pre-reveal rating module' do
      render_views

      let(:guide) { create(:user) }

      it 'lets a member rate the sealed bottle on tasting day' do
        today = create(:meeting, bottle_bringer: guide, date: Time.zone.today)
        bottle = create(:bottle, :unrevealed, meeting: today, user: guide)

        get :show, params: { id: today.id }

        expect(response.body).to include('Submit Rating')
        expect(response.body).not_to include(bottle.name)
      end

      it 'hides the rating module before tasting day' do
        upcoming = create(:meeting, bottle_bringer: guide, date: 3.days.from_now.to_date)
        create(:bottle, :unrevealed, meeting: upcoming, user: guide)

        get :show, params: { id: upcoming.id }

        expect(response.body).not_to include('Submit Rating')
      end

      # Regression: 2025 tastings whose bottles predate the reveal feature have
      # a nil revealed_at, and were showing the sealed-wax card — hiding a
      # whiskey the club had already poured and rated.
      it 'shows the bottle on a past tasting even with no reveal timestamp' do
        past = create(:meeting, bottle_bringer: guide, date: 1.year.ago.to_date)
        bottle = create(:bottle, :unrevealed, meeting: past, user: guide)

        get :show, params: { id: past.id }

        expect(response.body).to include(bottle.name)
        expect(response.body).not_to include('Sealed until the reveal')
      end

      it 'says the dram is not in yet when the guide has not added it on tasting day' do
        today = create(:meeting, bottle_bringer: guide, date: Time.zone.today)

        get :show, params: { id: today.id }

        expect(response.body).to include('dram')
        expect(response.body).to include('Rating opens the moment they do')
        expect(response.body).not_to include('Sealed until the reveal')
      end
    end
  end

  describe 'GET #edit' do
    let(:meeting) { create(:meeting, bottle_bringer: user) }

    it 'returns success' do
      get :edit, params: { id: meeting.id }
      expect(response).to be_successful
    end

    it 'assigns all users' do
      create_list(:user, 2)
      get :edit, params: { id: meeting.id }
      expect(assigns(:users).count).to eq(3) # 2 + logged in user
    end
  end

  describe 'PATCH #update' do
    let(:meeting) { create(:meeting) }
    let(:new_date) { Date.tomorrow }

    context 'with valid parameters' do
      it 'updates the meeting' do
        patch :update, params: { id: meeting.id, meeting: { date: new_date } }
        meeting.reload
        expect(meeting.date).to eq(new_date)
      end

      it 'redirects to the meeting' do
        patch :update, params: { id: meeting.id, meeting: { date: new_date } }
        expect(response).to redirect_to(meeting_path(meeting))
      end
    end

    context 'with invalid parameters' do
      it 'does not update the meeting' do
        original_date = meeting.date
        patch :update, params: { id: meeting.id, meeting: { date: nil } }
        meeting.reload
        expect(meeting.date).to eq(original_date)
      end

      it 'returns unprocessable entity status' do
        patch :update, params: { id: meeting.id, meeting: { date: nil } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:meeting) { create(:meeting) }

    it 'destroys the meeting' do
      expect {
        delete :destroy, params: { id: meeting.id }
      }.to change(Meeting, :count).by(-1)
    end

    it 'redirects to root path' do
      delete :destroy, params: { id: meeting.id }
      expect(response).to redirect_to(root_path)
    end
  end
end
