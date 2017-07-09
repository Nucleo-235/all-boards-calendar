module ApplicationHelper
  def get_localized_value(locals)
    localized_page = locals[:localized_page]
    key = locals[:key]
    default_value = locals[:default_value]
    localized_page.get_value(key, default_value).value
  end

  def should_show?(optional_string_value)
    @is_admin || !optional_string_value.blank?
  end

  def calendar_url(url_helpers, host, property)
    args = { code: '_C_', format: :ics, host: host }
    "'#{url_helpers.calendar_url(args)}'.replace('_C_', user.#{property})"
  end
end
