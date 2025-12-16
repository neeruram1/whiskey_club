require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#form_input_classes' do
    let(:object) { double('object') }

    context 'without errors' do
      before do
        allow(object).to receive_message_chain(:errors, :[]).and_return([])
      end

      it 'returns base classes' do
        expect(helper.form_input_classes(object, :name)).to include('mt-2')
        expect(helper.form_input_classes(object, :name)).to include('block')
        expect(helper.form_input_classes(object, :name)).to include('w-full')
      end

      it 'returns border-gray-300 for valid field' do
        expect(helper.form_input_classes(object, :name)).to include('border-gray-300')
      end
    end

    context 'with errors' do
      before do
        allow(object).to receive_message_chain(:errors, :[]).and_return(['is required'])
      end

      it 'returns error classes' do
        expect(helper.form_input_classes(object, :name)).to include('border-red-500')
        expect(helper.form_input_classes(object, :name)).to include('focus:border-red-500')
      end

      it 'does not include valid border color' do
        expect(helper.form_input_classes(object, :name)).not_to include('border-gray-300')
      end
    end
  end

  describe '#form_label_classes' do
    let(:object) { double('object') }

    context 'without errors' do
      before do
        allow(object).to receive_message_chain(:errors, :[]).and_return([])
      end

      it 'returns base label classes' do
        expect(helper.form_label_classes(object, :name)).to include('block')
        expect(helper.form_label_classes(object, :name)).to include('text-sm')
        expect(helper.form_label_classes(object, :name)).to include('font-medium')
      end

      it 'returns default text color' do
        expect(helper.form_label_classes(object, :name)).to include('text-gray-700')
      end
    end

    context 'with errors' do
      before do
        allow(object).to receive_message_chain(:errors, :[]).and_return(['is required'])
      end

      it 'returns error text color' do
        expect(helper.form_label_classes(object, :name)).to include('text-red-600')
      end
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
        expect(result).to include('text-sm')
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
      expect(result).to include('px-4')
      expect(result).to include('py-2')
      expect(result).to include('border')
      expect(result).to include('bg-white')
      expect(result).to include('text-gray-700')
    end

    it 'includes hover states' do
      result = helper.form_cancel_button_classes
      expect(result).to include('hover:bg-gray-50')
    end
  end
end
