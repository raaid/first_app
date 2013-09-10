class Comment < ActiveRecord::Base
  belongs_to :event
  #validates :user_id, presence: true
end
