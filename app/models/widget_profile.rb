class WidgetProfile < ActiveRecord::Base
  #attr_accessible :events_background, :tickets_background, :user_id
  belongs_to :user
end
