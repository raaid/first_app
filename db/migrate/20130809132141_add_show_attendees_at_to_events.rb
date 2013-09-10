class AddShowAttendeesAtToEvents < ActiveRecord::Migration
  def change
    add_column :events, :show_attendees_at, :int
  end
end
