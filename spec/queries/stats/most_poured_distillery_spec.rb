require 'rails_helper'

RSpec.describe Stats::MostPouredDistillery do
  describe '.call' do
    it 'returns the most-represented distillery and its bottle count' do
      create(:bottle, distillery: 'Lagavulin')
      create(:bottle, distillery: 'Lagavulin')
      create(:bottle, distillery: 'Ardbeg')

      expect(described_class.call).to eq(['Lagavulin', 2])
    end

    it 'ignores blank distilleries' do
      create(:bottle, distillery: 'Oban')

      distillery, count = described_class.call
      expect(distillery).to eq('Oban')
      expect(count).to eq(1)
    end
  end
end
