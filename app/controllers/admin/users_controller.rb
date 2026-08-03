class Admin::UsersController < ApplicationController
  before_action :require_admin

  def index
    @users = User.order(:created_at)
  end

  def destroy
    user = User.find(params[:id])

    if user == current_user
      redirect_to admin_users_path, alert: "You can't delete your own account." and return
    end

    Meeting.where(bottle_bringer_id: user.id).update_all(bottle_bringer_id: nil)
    user.destroy

    redirect_to admin_users_path, notice: "#{user.full_name} was removed."
  end

  private

  def require_admin
    redirect_to root_path, alert: "Not authorized." unless current_user&.admin?
  end
end
