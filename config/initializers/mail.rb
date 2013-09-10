#ActionMailer::Base.smtp_settings = {
#  :address        => 'smtp.sendgrid.net',
#  :port           => '587',
#  :authentication => :plain,
#  :user_name      => ENV['SENDGRID_USERNAME'],
#  :password       => ENV['SENDGRID_PASSWORD'],
#  :domain         => 'heroku.com'
#}

#switch config.action_mailer.delivery_method in /config/environments/development.rb to :smtp
ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "gmail.com",
  :user_name            => "ticketacular@gmail.com",
  :password             => "Giftwish1",
  :authentication       => "plain",
  :enable_starttls_auto => true
}