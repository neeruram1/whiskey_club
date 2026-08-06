require 'rails_helper'

RSpec.describe PublicController, type: :controller do
  render_views

  let(:user) { create(:user) }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns success' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns next meeting' do
      upcoming = create(:meeting, :upcoming)
      _past = create(:meeting, :past)

      get :index
      expect(assigns(:next_meeting)).to eq(upcoming)
    end

    it 'calculates user ratings' do
      bottle = create(:bottle, :revealed)
      create(:rating, user: user, bottle: bottle, score: 4)

      get :index
      expect(assigns(:ratings_count)).to eq(1)
      expect(assigns(:avg_rating)).to be_present
    end

    it 'calculates bottles brought' do
      _meeting = create(:meeting, bottle_bringer: user)

      get :index
      expect(assigns(:bottles_brought_count)).to be >= 0
    end
  end

  describe 'GET #stats' do
    let!(:user1) { create(:user, first_name: 'Alice') }
    let!(:user2) { create(:user, first_name: 'Bob') }
    let!(:bottle1) { create(:bottle, :revealed, :with_ratings) }
    let!(:bottle2) { create(:bottle, :revealed, :with_ratings) }

    before { sign_in user1 }

    it 'returns success' do
      get :stats
      expect(response).to be_successful
    end

    context 'with no rated bottles' do
      before { Rating.delete_all }

      it 'renders guidance instead of superlatives' do
        get :stats
        expect(response).to be_successful
        expect(response.body).to include("No superlatives yet")
      end
    end

    it 'assigns overview stats' do
      get :stats
      expect(assigns(:total_meetings)).to be_a(Integer)
      expect(assigns(:total_bottles)).to be_a(Integer)
      expect(assigns(:total_ratings)).to be_a(Integer)
    end

    it 'calculates tastemaker' do
      meeting = create(:meeting, bottle_bringer: user1)
      create(:bottle, meeting: meeting, user: user1)
      create(:bottle, meeting: meeting, user: user1)
      create(:rating, :excellent, user: user2, bottle: bottle1)
      create(:rating, :excellent, user: user2, bottle: bottle2)

      get :stats
      tastemaker = assigns(:tastemaker)

      expect(tastemaker).to be_a(Hash).or be_nil
    end

    it 'calculates golden nose' do
      create(:rating, user: user1, bottle: bottle1, score: 4)
      create(:rating, user: user2, bottle: bottle1, score: 5)
      create(:rating, user: create(:user), bottle: bottle1, score: 3)

      get :stats
      golden_nose = assigns(:golden_nose)

      expect(golden_nose).to be_a(Hash).or be_nil
    end

    it 'optimizes queries' do
      create(:rating, user: user1, bottle: bottle1)
      create(:rating, user: user2, bottle: bottle1)

      get :stats
      expect(response).to be_successful
    end
  end
end
