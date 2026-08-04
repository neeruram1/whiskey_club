require 'rails_helper'

RSpec.describe Stats::RaterExtremes do
  let(:harsh) { create(:user) }
  let(:generous) { create(:user) }

  before do
    3.times { create(:rating, user: harsh, score: 1) }
    3.times { create(:rating, user: generous, score: 5) }
  end

  it 'reports the lowest-average rater as hardest' do
    expect(described_class.hardest).to eq(harsh)
  end

  it 'reports the highest-average rater as easiest' do
    expect(described_class.easiest).to eq(generous)
  end

  it 'ignores members with fewer than 3 ratings' do
    occasional = create(:user)
    create(:rating, user: occasional, score: 0)

    expect(described_class.hardest).to eq(harsh)
  end
end
