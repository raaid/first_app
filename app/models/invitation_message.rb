class InvitationMessage < ActiveRecord::Base
  belongs_to :owner
  attr_accessible :name, :text, :video, :id, :owner, :owner_id, :event_id
end
