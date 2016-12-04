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
end
