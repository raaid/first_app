module ApplicationHelper
  # Crude admin stuff, for now.
  redirect_non_admins_to = "/"
  def admin
    return current_user != nil
  end

  def ticketing_is_enabled
    true
  end

  def page_title_helper(title)
    "<h1>#{sanitize(title)}</h1><hr><br />".html_safe
  end

  def background_slide
    "<script>
  $(document).ready(function () {
  });
</script>".html_safe
  end

  def background_fade
    "<script>
</script>".html_safe
  end


  def hinted_text_field_tag(name, value = nil, hint = "Click and enter text", options={})
    value = value.nil? ? hint : value
    text_field_tag name, value, {:onclick => "if($(this).value == '#{hint}'){$(this).value = ''}", :onblur => "if($(this).value == ''){$(this).value = '#{hint}'}" }.update(options.stringify_keys)
  end
end
