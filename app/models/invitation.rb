class Invitation < ActiveRecord::Base
  belongs_to :invited
  belongs_to :invited_to
  belongs_to :user

  attr_accessible :invited, :invited_id, :invited_to, :invited_to_id, :owner, :email, :name
end
