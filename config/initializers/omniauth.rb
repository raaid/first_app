Rails.application.config.middleware.use OmniAuth::Builder do
  #Production
  provider :facebook, '448543725167738', 'e92513dd661e430e3d5f7c269f9b2a38', :scope => 'publish_stream,email,offline_access,manage_pages,user_birthday,publish_actions,user_location'
  #localhost
  #provider :facebook, '504545792924158', '33ea69c096d97af304d6c98efe027bd3', :scope => 'publish_stream,email,offline_access,manage_pages,user_birthday,publish_actions,user_location'
end
