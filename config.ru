# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

AUTH_PASSWORD = ENV['RESQUE_PASSWORD']

if AUTH_PASSWORD
  Resque::Server.use Rack::Auth::Basic do |username, password|
    password == AUTH_PASSWORD
  end
end

run Ticketacular::Application

