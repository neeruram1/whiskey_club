require 'rails_helper'

RSpec.describe Rating, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:score) }
    it { should validate_inclusion_of(:score).in_range(0..5) }
    it { should validate_length_of(:comment).is_at_most(500) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:bottle) }
  end
end
