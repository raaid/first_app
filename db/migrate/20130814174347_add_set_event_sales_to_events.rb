class AddSetEventSalesToEvents < ActiveRecord::Migration
  def change
    add_column :events, :set_event_sales, :boolean
  end
end
