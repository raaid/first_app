require "resque/tasks"

#task "resque:setup" => :environment
task "resque:setup" => :environment do
  ENV['QUEUE'] = '*'
  Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
end

desc "Alias for resque:work (To run workers on Heroku)"
task "jobs:work" => "resque:work"

#namespace :resque do
#  task setup: :environment do
#    ENV['QUEUE'] ||= '*'
#    Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
#    Dir["#{Rails.root}/app/workers/*.rb"].each { |file| require file }
#  end
#end

#namespace :jobs do
#  task work: "resque:work"
#end