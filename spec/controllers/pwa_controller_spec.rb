require 'rails_helper'

RSpec.describe PwaController, type: :controller do
  render_views

  # The browser fetches all three of these itself, sometimes with no session
  # attached, so none of them may bounce to the login page.
  describe 'GET #manifest' do
    it 'is served without signing in' do
      get :manifest

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq('application/manifest+json')
    end

    it 'describes an installable standalone app' do
      get :manifest
      # Not response.parsed_body: it doesn't parse application/manifest+json,
      # and it hands back the raw string instead.
      manifest = JSON.parse(response.body) # rubocop:disable Rails/ResponseParsedBody

      expect(manifest['name']).to eq('Collective Spirits of Montclair')
      expect(manifest['display']).to eq('standalone')
      expect(manifest['start_url']).to eq('/')
    end

    it 'ships icons Android and the install prompt need' do
      get :manifest
      icons = JSON.parse(response.body)['icons'] # rubocop:disable Rails/ResponseParsedBody

      expect(icons.pluck('sizes')).to include('192x192', '512x512')
      # Without a maskable icon Android frames the seal in a white box.
      expect(icons.pluck('purpose')).to include('maskable')
      expect(icons).to all(include('src' => a_string_matching(%r{\A/assets/})))
    end
  end

  describe 'GET #service_worker' do
    it 'is served as JavaScript without signing in' do
      get :service_worker

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq('text/javascript')
    end

    it 'is never cached, so the app cannot get stuck on a stale worker' do
      get :service_worker

      expect(response.headers['Cache-Control']).to eq('no-store')
    end

    it 'points at the offline fallback it precaches' do
      get :service_worker

      expect(response.body).to include(pwa_offline_path)
    end
  end

  describe 'GET #offline' do
    it 'renders standalone without signing in' do
      get :offline

      expect(response).to have_http_status(:ok)
      # Styles are inline so the page still renders with no network and no
      # cached stylesheet.
      expect(response.body).to include('<style>')
      expect(response.body).not_to include('Main navigation')
    end
  end
end
