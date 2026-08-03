# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]
  layout :resolve_layout

  # POST /resource
  def create
    if params.dig(:user, :invite_code).to_s.strip != ENV["CLUB_INVITE_CODE"].to_s
      self.resource = resource_class.new(sign_up_params)
      resource.validate
      flash.now[:alert] = "Invalid invite code. Contact a club member for access."
      respond_with(resource) do |format|
        format.html { render :new, status: :unprocessable_entity }
      end
      return
    end

    super
  end

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
