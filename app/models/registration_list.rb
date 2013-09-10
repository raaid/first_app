class RegistrationList < ActiveRecord::Base
  belongs_to :event
  has_many :registration_members
end
