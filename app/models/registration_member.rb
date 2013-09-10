class RegistrationMember < ActiveRecord::Base
  attr_accessible :registration_list_id, :email, :name

  belongs_to :registration_list

  validates :name, presence: true
  validates :email, presence: true

end
