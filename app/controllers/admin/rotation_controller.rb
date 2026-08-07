class Admin::RotationController < Admin::BaseController
  def index
    @members = Rotation.members
    @candidates = Rotation.candidates
    @next_guide = Rotation.next_guide
  end

  def add
    Rotation.add(User.find(params[:user_id]))
    redirect_to admin_rotation_path, notice: "Added to the rotation."
  end

  def remove
    Rotation.remove(User.find(params[:user_id]))
    redirect_to admin_rotation_path, notice: "Removed from the rotation."
  end

  def move
    Rotation.move(User.find(params[:user_id]), params[:direction])
    redirect_to admin_rotation_path
  end
end
