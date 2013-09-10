class ContactListMember < ActiveRecord::Base
  belongs_to :user
  belongs_to :contact_list
  attr_accessible :email, :name, :contact_list_id, :id
end
