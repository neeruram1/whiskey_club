require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#form_input_classes' do
    context 'without errors' do
      it 'returns base classes' do
        result = helper.form_input_classes
        expect(result).to include('block')
        expect(result).to include('w-full')
      end

      it 'returns lagavulin-green border for valid field' do
        result = helper.form_input_classes
        expect(result).to include('border-lagavulin-green/30')
      end
    end

    context 'with errors' do
      it 'returns error classes' do
        result = helper.form_input_classes(errors_present: true)
        expect(result).to include('border-red-500')
        expect(result).to include('bg-red-50')
      end

      it 'does not include valid border color' do
        result = helper.form_input_classes(errors_present: true)
        expect(result).not_to include('border-lagavulin-green/30')
      end
    end
  end

  describe '#form_label_classes' do
    it 'returns base label classes' do
      result = helper.form_label_classes
      expect(result).to include('block')
      expect(result).to include('label-sm')
    end

    it 'returns lagavulin-green text color' do
      result = helper.form_label_classes
      expect(result).to include('text-lagavulin-green')
    end
  end

  describe '#form_error_message' do
    let(:object) { double('object') }

    context 'without errors' do
      before do
        allow(object).to receive_message_chain(:errors, :[]).and_return([])
      end

      it 'returns nil' do
        expect(helper.form_error_message(object, :name)).to be_nil
      end
    end

    context 'with errors' do
      before do
        allow(object).to receive_message_chain(:errors, :[]).and_return(['is required', 'is too short'])
      end

      it 'returns formatted error message' do
        result = helper.form_error_message(object, :name)
        expect(result).to include('text-red-600')
        expect(result).to include('meta-xs')
        expect(result).to include('mt-1')
        expect(result).to include('is required')
      end

      it 'returns first error only' do
        result = helper.form_error_message(object, :name)
        expect(result).to include('is required')
        expect(result).not_to include('is too short')
      end
    end
  end

  describe '#form_cancel_button_classes' do
    it 'returns cancel button classes' do
      result = helper.form_cancel_button_classes
      expect(result).to include('inline-flex')
      expect(result).to include('items-center')
      expect(result).to include('px-6')
      expect(result).to include('py-3')
      expect(result).to include('border')
      expect(result).to include('bg-white')
      expect(result).to include('text-gray-700')
    end

    it 'includes hover states' do
      result = helper.form_cancel_button_classes
      expect(result).to include('hover:bg-gray-50')
    end
  end

  describe '#club_location' do
    it 'falls back to a friendly default when unset' do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('CLUB_LOCATION').and_return(nil)
      expect(helper.club_location).to eq('our usual spot')
    end

    it 'uses CLUB_LOCATION when configured' do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('CLUB_LOCATION').and_return("Dan's place")
      expect(helper.club_location).to eq("Dan's place")
    end
  end

  describe '#google_calendar_url' do
    let(:guide) { create(:user, first_name: 'Ava', last_name: 'Guide') }

    it 'builds a Google render URL with an all-day range when no time is set' do
      meeting = create(:meeting, bottle_bringer: guide, date: Date.new(2026, 9, 12), start_time: nil)
      url = helper.google_calendar_url(meeting)
      params = Rack::Utils.parse_query(URI(url).query)
      expect(url).to start_with('https://calendar.google.com/calendar/render')
      expect(params['action']).to eq('TEMPLATE')
      expect(params['dates']).to eq('20260912/20260913')
      expect(params['text']).to eq('Whiskey Tasting — Ava Guide guides')
    end

    it 'uses a timed 2-hour range when a start time is set' do
      meeting = create(:meeting, bottle_bringer: guide, date: Date.new(2026, 9, 12), start_time: '19:00')
      params = Rack::Utils.parse_query(URI(helper.google_calendar_url(meeting)).query)
      expect(params['dates']).to eq('20260912T190000/20260912T210000')
      expect(params['ctz']).to eq('America/New_York')
    end
  end
end
