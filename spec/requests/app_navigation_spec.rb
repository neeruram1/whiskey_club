require 'rails_helper'

# The installed app has no browser toolbar, so the layout supplies its own
# navigation. All of it is gated behind the standalone: CSS variant — these
# specs check the markup ships and is labelled correctly, not that a browser
# tab displays it.
RSpec.describe 'App navigation', type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe 'the bottom tab bar' do
    it 'renders the four sections' do
      get meetings_path

      expect(response.body).to include('aria-label="Sections"')
      %w[Home Tastings Bottles Stats].each do |label|
        expect(response.body).to include(">#{label}</span>")
      end
    end

    it 'marks the section you are in as current, even one level deep' do
      meeting = create(:meeting)

      get meeting_path(meeting)

      expect(response.body).to include('aria-current="page"')
    end

    it 'stays out of the signed-out pages, which hide the whole shell' do
      sign_out user

      get new_user_session_path

      expect(response.body).not_to include('aria-label="Sections"')
    end
  end

  describe 'the back button' do
    it 'is absent on a section root, which the tab bar already reaches' do
      get meetings_path

      expect(response.body).not_to include('aria-label="Go back"')
    end

    it 'is present once you have drilled into a page' do
      meeting = create(:meeting)

      get meeting_path(meeting)

      expect(response.body).to include('aria-label="Go back"')
      expect(response.body).to include('data-controller="back"')
    end
  end
end
