ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

# from http://rdoc.info/github/binarylogic/authlogic/master/Authlogic/TestCase
require "authlogic/test_case" # include at the top of test_helper.rb

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  setup :activate_authlogic # run before tests are executed

  def login(user=:john_doe)
    logout
    Session.create(users(user)) # logs a user in
  end

  def logout
    @session = Session.find
    if @session
      @session.destroy # removes any logged in user that might exist
    end
  end
end
