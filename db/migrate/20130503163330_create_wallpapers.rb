class CreateWallpapers < ActiveRecord::Migration
  def change
    create_table :wallpapers do |t|
      t.integer :event_id
      t.string :wallpaper_file_name
      t.string :wallpaper_content_type
      t.string :wallpaper_file_size

      t.timestamps
    end
  end
end
