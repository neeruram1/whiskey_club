require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
  end

  describe 'associations' do
    it { should have_many(:ratings) }
    it { should have_many(:bottles) }
    it { should have_many(:meeting_attendees) }
    it { should have_many(:meetings).through(:meeting_attendees) }
  end

  describe 'guide track record' do
    let(:guide) { create(:user) }

    it 'counts the tastings guided' do
      expect(guide.times_guiding).to eq(0)
      create(:meeting, bottle_bringer: guide)
      create(:meeting, bottle_bringer: guide)
      expect(guide.times_guiding).to eq(2)
    end

    it 'averages the club rating across their pours' do
      meeting = create(:meeting, bottle_bringer: guide)
      bottle = create(:bottle, meeting: meeting, user: guide)
      create(:rating, bottle: bottle, score: 4)
      create(:rating, bottle: bottle, score: 5)
      expect(guide.pours_average_score.to_f).to eq(4.5)
    end

    it 'returns nil when their pours are unrated' do
      expect(guide.pours_average_score).to be_nil
    end
  end
end
