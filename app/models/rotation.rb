# The spirit-guide rotation: an ordered list of members the club takes turns
# guiding in. Positions are stored on User#rotation_position (nil = not in the
# rotation). This class owns the ordering and the "whose turn is next" logic and
# is the single place that mutates the order, so positions stay contiguous.
class Rotation
  # Members currently in the rotation, in turn order.
  def self.members
    User.in_rotation.to_a
  end

  # Members not yet in the rotation, available to add.
  def self.candidates
    User.not_in_rotation.to_a
  end

  # The member whose turn is next: the one after the most recent tasting's guide,
  # wrapping around. Falls back to the first member when we can't tell (no past
  # tastings with a guide from the rotation). Returns nil for an empty rotation.
  def self.next_guide
    ordered = members
    return nil if ordered.empty?

    ids = ordered.map(&:id)
    last_guide_id = Meeting.where(bottle_bringer_id: ids)
                           .order(date: :desc, created_at: :desc)
                           .limit(1)
                           .pick(:bottle_bringer_id)

    idx = ids.index(last_guide_id)
    idx.nil? ? ordered.first : ordered[(idx + 1) % ordered.size]
  end

  # Append a member to the end of the rotation.
  def self.add(user)
    return if user.rotation_position.present?

    user.update!(rotation_position: (User.in_rotation.maximum(:rotation_position) || 0) + 1)
    reindex
  end

  # Remove a member from the rotation and close the gap.
  def self.remove(user)
    user.update!(rotation_position: nil)
    reindex
  end

  # Move a member one step earlier (:up) or later (:down) in the order.
  def self.move(user, direction)
    ordered = members
    idx = ordered.index { |u| u.id == user.id }
    return if idx.nil?

    swap_with = direction.to_sym == :up ? idx - 1 : idx + 1
    return if swap_with.negative? || swap_with >= ordered.size

    other = ordered[swap_with]
    User.transaction do
      a = user.rotation_position
      b = other.rotation_position
      user.update!(rotation_position: b)
      other.update!(rotation_position: a)
    end
  end

  # Normalise positions to 1..n in current order, closing any gaps.
  def self.reindex
    User.in_rotation.each_with_index do |user, i|
      user.update_columns(rotation_position: i + 1) unless user.rotation_position == i + 1
    end
  end
end
