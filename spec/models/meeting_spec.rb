require 'rails_helper'

RSpec.describe Meeting, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:date) }
  end

  describe 'associations' do
    it { should have_one(:bottle).dependent(:destroy) }
    it { should have_one(:bottle_bringer).through(:bottle).source(:user) }
    it { should have_many(:meeting_attendees).dependent(:destroy) }
    it { is_expected.to have_many(:attendees).through(:meeting_attendees).source(:user) }
  end
end
