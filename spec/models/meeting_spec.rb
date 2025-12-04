require 'rails_helper'

RSpec.describe Meeting, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:date) }

    it "should not be a duplicate meeting on the same date" do
      meeting = (create :meeting, date: Date.today)
      duplicate_meeting = build(:meeting, date: Date.today)
      expect(duplicate_meeting).not_to be_valid
    end
  end

  describe 'associations' do
    it { should have_one(:bottle) }
    it { should belong_to(:bottle_bringer).class_name('User') }
    it { should have_many(:meeting_attendees).dependent(:destroy) }
    it { is_expected.to have_many(:attendees).through(:meeting_attendees).source(:user) }
  end
end
