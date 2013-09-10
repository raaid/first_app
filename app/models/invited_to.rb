class InvitedTo < ActiveRecord::Base
  belongs_to :last_message
  belongs_to :wedding_event
  belongs_to :owner
  # attr_accessible :title, :body
end
