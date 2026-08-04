require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("CLUB_INVITE_CODE").and_return("secret-dram")
  end

  let(:valid_user_params) do
    {
      first_name: "Jane",
      last_name: "Doe",
      email: "jane@example.com",
      password: "password",
      password_confirmation: "password"
    }
  end

  describe 'POST #create' do
    context 'with the correct invite code' do
      it 'creates a user' do
        expect {
          post :create, params: { user: valid_user_params.merge(invite_code: "secret-dram") }
        }.to change(User, :count).by(1)
      end
    end

    context 'with a wrong invite code' do
      it 'does not create a user and re-renders the form' do
        expect {
          post :create, params: { user: valid_user_params.merge(invite_code: "wrong") }
        }.not_to change(User, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to be_present
      end
    end

    context 'with a blank invite code' do
      it 'does not create a user' do
        expect {
          post :create, params: { user: valid_user_params.merge(invite_code: "") }
        }.not_to change(User, :count)
      end
    end
  end
end
