# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]
  layout :resolve_layout

  # GET /resource/edit
  def edit
    if turbo_frame_request?
      render :edit_modal, layout: false
    else
      super
    end
  end

  # PUT /resource
  def update
    super do |resource|
      if resource.errors.any?
        if turbo_frame_request?
          render :edit_modal, layout: false and return
        end
      else
        # Redirect to root after successful update
        redirect_to root_path, notice: "Account updated successfully." and return
      end
    end
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name])
  end

  private

  def resolve_layout
    case action_name
    when "edit"
      turbo_frame_request? ? false : "application"
    else
      "application"
    end
  end
end
