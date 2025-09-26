require 'rails_helper'

RSpec.describe MeetingAttendee, type: :model do
  describe 'validations' do
    subject { create(:meeting_attendee) }  # needed for scoped uniqueness
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:meeting_id) }
    it { should validate_presence_of(:meeting_id) }
    it { should validate_presence_of(:user_id) }
  end

  describe 'associations' do
    it { should belong_to(:meeting) }
    it { should belong_to(:user) }
  end
end
