class ContactList < ActiveRecord::Base
  attr_accessible :name, :owner, :owner_id, :id, :contact_list_members , :event_id, :admin
  has_many :contact_list_members, dependent: :destroy
end
