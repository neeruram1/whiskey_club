require 'rails_helper'

RSpec.describe Bottle, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:distillery) }
    it { should validate_numericality_of(:age).only_integer.is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:final_score).is_greater_than(0) }
  end

  describe 'associations' do
    it { should have_many(:ratings) }
    it { should belong_to(:user) }
    it { should belong_to(:meeting).optional }
  end
end
