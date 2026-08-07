module ApplicationHelper
  def friendly_date(date)
    return "" unless date

    days_ago = (Time.zone.today - date.to_date).to_i
    
    case days_ago
    when 0
      "Today"
    when 1
      "Yesterday"
    when 2..6
      "#{days_ago} days ago"
    when 7..13
      "Last week"
    when 14..29
      "#{(days_ago / 7).round} weeks ago"
    when 30..59
      "Last month"
    else
      date.strftime("%B %Y")
    end
  end

  def date_with_friendly(date, format: "%B %-d, %Y")
    return "" unless date
    
    days_ago = (Time.zone.today - date.to_date).to_i
    
    # Show relative for recent dates (within 2 weeks)
    if days_ago <= 14
      content_tag(:span, title: date.strftime(format)) do
        friendly_date(date)
      end
    else
      date.strftime(format)
    end
  end

  # Generate form input classes with error state support
  def form_input_classes(errors_present: false)
    base = "block w-full rounded-xl border px-3.5 py-3 text-base text-gray-900 placeholder:text-gray-400 shadow-sm focus:border-lagavulin-green focus:outline-none focus:ring-4 focus:ring-lagavulin-green/20"
    
    if errors_present
      "#{base} border-red-500 bg-red-50"
    else
      "#{base} border-lagavulin-green/30 bg-white"
    end
  end

  # Generate form label classes
  def form_label_classes
    "mb-2 block label-sm text-lagavulin-green"
  end

  # Generate form error message
  def form_error_message(object, attribute, id: nil)
    return unless object.errors[attribute].any?
    
    content_tag(:p, object.errors[attribute].first, 
                class: "mt-1 meta-xs text-red-600",
                id: id)
  end

  # The club's usual gathering spot, configurable per environment. Per-meeting
  # locations (for future club outings) can override this down the road.
  def club_location
    ENV["CLUB_LOCATION"].presence || "our usual spot"
  end

  # Small gold "pill" badge used across stat cards.
  def gold_pill(text)
    content_tag(:div, class: "rounded-full bg-lagavulin-gold/20 border border-lagavulin-gold/40 px-3 py-1") do
      content_tag(:p, text, class: "meta-xs text-lagavulin-gold font-semibold")
    end
  end

  # Generate cancel button classes for forms
  def form_cancel_button_classes
    "inline-flex w-full md:w-auto items-center justify-center rounded-xl border-2 border-gray-400 bg-white px-6 py-3 text-sm tracking-widest uppercase font-semibold text-gray-700 shadow-lg shadow-black/50 transition-all duration-200 hover:bg-gray-50 hover:border-gray-500 hover:shadow-xl hover:shadow-black/60 focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-gray-400/40 order-2 sm:order-1"
  end
end
