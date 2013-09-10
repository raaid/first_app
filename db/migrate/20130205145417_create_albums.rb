class CreateAlbums < ActiveRecord::Migration
  def change
      create_table :albums do |t|
        t.string   :name
        t.string   :description
        t.integer  :event_id
        t.integer  :private
        t.timestamps
      end
    end
end
