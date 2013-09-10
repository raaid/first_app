class InvitationResponse < ActiveRecord::Base
  belongs_to :invitation
  attr_accessible :description, :status, :invitation_id, :invitation
end
