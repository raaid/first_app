class Album < ActiveRecord::Base
  attr_accessible :description, :name, :private, :event_id, :id

  belongs_to :event
  has_many :album_photos
end
