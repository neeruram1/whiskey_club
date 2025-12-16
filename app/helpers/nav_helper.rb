module NavHelper
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
