desc "This task is called by the Heroku scheduler add-on"

task :daily_metrics => :environment do
  #require 'active_support/core_ext/numeric/time'
  Notifier.daily_metrics("Support", "support@eventastic.com").deliver
  #Notifier.daily_metrics("Randy", "randy@giftopia.me").deliver
  Notifier.daily_metrics("Laurie Paleczny", "laurie.paleczny@dashdigitalgroup.com").deliver
end