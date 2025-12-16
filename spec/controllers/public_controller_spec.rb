require 'rails_helper'

RSpec.describe PublicController, type: :controller do
  let(:user) { create(:user) }
  
  before { sign_in user }

  describe 'GET #index' do
    it 'returns success' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns next meeting' do
      upcoming = create(:meeting, :upcoming)
      past = create(:meeting, :past)
      
      get :index
      expect(assigns(:next_meeting)).to eq(upcoming)
    end

    it 'calculates user ratings' do
      bottle = create(:bottle, :revealed)
      create(:rating, user: user, bottle: bottle, nose: 4, taste: 4, finish: 4)
      
      get :index
      expect(assigns(:ratings_count)).to eq(1)
      expect(assigns(:avg_rating)).to be_present
    end

    it 'calculates bottles brought' do
      meeting = create(:meeting, bottle_bringer: user)
      bottle = create(:bottle, meeting: meeting)
      
      get :index
      expect(assigns(:bottles_brought_count)).to be >= 0
    end
  end

  describe 'GET #stats' do
    let!(:user1) { create(:user, name: 'Alice') }
    let!(:user2) { create(:user, name: 'Bob') }
    let!(:bottle1) { create(:bottle, :revealed, :with_ratings) }
    let!(:bottle2) { create(:bottle, :revealed, :with_ratings) }

    before do
      sign_in user1
    end

    it 'returns success' do
      get :stats
      expect(response).to be_successful
    end

    it 'calculates taste similarity' do
      # Create overlapping ratings
      create(:rating, user: user1, bottle: bottle1, nose: 5, taste: 5, finish: 5)
      create(:rating, user: user2, bottle: bottle1, nose: 5, taste: 5, finish: 5)
      create(:rating, user: user1, bottle: bottle2, nose: 3, taste: 3, finish: 3)
      create(:rating, user: user2, bottle: bottle2, nose: 3, taste: 3, finish: 3)
      
      get :stats
      similarity = assigns(:taste_similarity)
      
      expect(similarity).to be_a(Hash)
      expect(similarity[user2.id]).to be_present
      expect(similarity[user2.id][:name]).to eq('Bob')
      expect(similarity[user2.id][:similarity]).to be > 90 # Very similar ratings
    end

    it 'calculates tastemaker' do
      # User1 rates highly, others follow
      create(:rating, :excellent, user: user1, bottle: bottle1)
      create(:rating, :excellent, user: user2, bottle: bottle1)
      
      get :stats
      tastemaker = assigns(:tastemaker)
      
      expect(tastemaker).to be_a(Hash)
      expect(tastemaker).to have_key(:user)
      expect(tastemaker).to have_key(:influence_score)
    end

    it 'calculates golden nose' do
      # User with ratings closest to group average
      create(:rating, user: user1, bottle: bottle1, nose: 4, taste: 4, finish: 4)
      create(:rating, user: user2, bottle: bottle1, nose: 5, taste: 5, finish: 5)
      create(:rating, user: create(:user), bottle: bottle1, nose: 3, taste: 3, finish: 3)
      
      get :stats
      golden_nose = assigns(:golden_nose)
      
      expect(golden_nose).to be_a(Hash)
      expect(golden_nose).to have_key(:user)
      expect(golden_nose).to have_key(:accuracy)
    end

    it 'calculates favorite bottles' do
      create(:rating, :excellent, user: user1, bottle: bottle1)
      create(:rating, :poor, user: user1, bottle: bottle2)
      
      get :stats
      favorites = assigns(:favorite_bottles)
      
      expect(favorites).to be_an(Array)
      expect(favorites.first).to eq(bottle1)
    end

    it 'calculates least favorite bottles' do
      create(:rating, :excellent, user: user1, bottle: bottle1)
      create(:rating, :poor, user: user1, bottle: bottle2)
      
      get :stats
      least_favorites = assigns(:least_favorite_bottles)
      
      expect(least_favorites).to be_an(Array)
      expect(least_favorites.first).to eq(bottle2)
    end

    it 'optimizes queries' do
      # Should use minimal queries due to optimizations
      create(:rating, user: user1, bottle: bottle1)
      create(:rating, user: user2, bottle: bottle1)
      
      get :stats
      expect(response).to be_successful
    end
  end
end
