class Contract < ActiveRecord::Base
  attr_accessible :commission, :event_id, :sales_person_id
end
