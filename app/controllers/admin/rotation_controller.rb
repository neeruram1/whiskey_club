class Admin::RotationController < Admin::BaseController
  def index
    @members = Rotation.members
    @candidates = Rotation.candidates
    @next_guide = Rotation.next_guide
    @scheduled_meeting = Meeting.upcoming.first
    @scheduled_guide_id = @scheduled_meeting&.bottle_bringer_id
  end

  # NB: redirect with :see_other (303) so Turbo follows it as a full page visit
  # rather than a turbo-stream fetch — otherwise the page silently never updates.
  def add
    Rotation.add(User.find(params[:user_id]))
    redirect_to admin_rotation_path, notice: "Added to the rotation.", status: :see_other
  end

  def remove
    Rotation.remove(User.find(params[:user_id]))
    redirect_to admin_rotation_path, notice: "Removed from the rotation.", status: :see_other
  end

  def move
    Rotation.move(User.find(params[:user_id]), params[:direction])
    redirect_to admin_rotation_path, status: :see_other
  end
end
