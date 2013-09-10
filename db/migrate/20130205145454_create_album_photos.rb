class CreateAlbumPhotos < ActiveRecord::Migration
  def change
      create_table :album_photos do |t|
        t.string   :album_photo_file_name
        t.string   :album_photo_content_type
        t.integer  :album_photo_file_size
        t.string   :caption
        t.integer  :album_id
        t.integer :approved
        t.timestamps
      end
    end
end
