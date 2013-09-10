class AddHasVideosToEvents < ActiveRecord::Migration
  def change
    add_column :events, :has_videos, :boolean
  end
end
