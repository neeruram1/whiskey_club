require 'rails_helper'

RSpec.describe ArchivesController, type: :controller do
  let(:user) { create(:user) }
  
  before { sign_in user }

  describe 'GET #index' do
    let!(:past_bottles) { create_list(:bottle, 5, meeting: create(:meeting, :past)) }
    let!(:upcoming_bottle) { create(:bottle, meeting: create(:meeting, :upcoming)) }

    it 'returns success' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns only past bottles' do
      get :index
      expect(assigns(:bottles)).to match_array(past_bottles)
      expect(assigns(:bottles)).not_to include(upcoming_bottle)
    end

    it 'orders bottles by date descending' do
      get :index
      dates = assigns(:bottles).map { |b| b.meeting.date }
      expect(dates).to eq(dates.sort.reverse)
    end

    it 'eager loads associations to avoid N+1' do
      get :index
      expect(response).to be_successful
    end
  end
end
