module NavHelper
  # The bottom bar's four sections. A tab stays lit for everything beneath it,
  # so /meetings/12 keeps "Tastings" active.
  def tab_current?(path)
    return request.path == path if path == "/"

    request.path == path || request.path.start_with?("#{path}/")
  end

  # Top-level destinations: the bottom bar already reaches them, so there's
  # nowhere for a back button to go.
  def section_root?
    [root_path, meetings_path, archives_path, stats_path, wishlist_path].include?(request.path)
  end

  def nav_config(label:, title: nil, back_to: nil, back_label: "Home", links: [], primary: nil)
    {
      label: label,
      title: title,
      back_to: back_to,
      back_label: back_label,
      links: links,
      primary: primary
    }
  end
end
