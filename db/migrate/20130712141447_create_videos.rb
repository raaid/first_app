class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.integer :event_id
      t.string :video
      t.boolean :has_youtube
      t.text :youtube
      t.boolean :default

      t.timestamps
    end
  end
end
