Ticketacular::Application.configure do
    # Settings specified here will take precedence over those in config/application.rb

    # In the development environment your application's code is reloaded on
    # every request.  This slows down response time but is perfect for development
    # since you don't have to restart the webserver when you make code changes.
    config.cache_classes = false

    # Log error messages when you accidentally call methods on nil.
    config.whiny_nils = true

    # Show full error reports and disable caching
    config.consider_all_requests_local       = true
    config.action_controller.perform_caching = false

  # Do not silently drop errors on development.
  config.action_mailer.raise_delivery_errors = true

    # Print deprecation notices to the Rails logger
    config.active_support.deprecation = :log

    # Only use best-standards-support built into browsers
    config.action_dispatch.best_standards_support = :builtin
    #config.action_mailer.delivery_method = :test
    config.action_mailer.delivery_method = :smtp
    #disable logging emails
    #config.action_mailer.logger = nil

    # From http://railscasts.com/episodes/146-paypal-express-checkout
    config.after_initialize do
    ActiveMerchant::Billing::Base.mode = :test
    ActiveMerchant::Billing::PaypalExpressGateway.default_currency = 'CAD'
      paypal_options = {
        :login => "derp_1351021425_biz_api1.giftopia.me",
        :password => "1351021447",
        :signature => "AFcWxV21C7fd0v3bYYYRCpSSRl31A8YbFIMCYK5Rw2ouBWD1snVUtgwq"
      }
      ::STANDARD_GATEWAY = ActiveMerchant::Billing::PaypalGateway.new(paypal_options)
      ::EXPRESS_GATEWAY = ActiveMerchant::Billing::PaypalExpressGateway.new(paypal_options)
    end
end
