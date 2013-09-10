class AddPosterToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :poster_file_name, :string
    add_column :videos, :poster_content_type, :string
    add_column :videos, :poster_file_size, :string
  end
end
