class AddConfigToEvents < ActiveRecord::Migration
  def change
    add_column :events, :set_options, :boolean
    add_column :events, :set_tickets, :boolean
    add_column :events, :set_donations, :boolean
    add_column :events, :set_cg, :boolean
    add_column :events, :set_social, :boolean
    add_column :events, :set_video, :boolean
    add_column :events, :set_photo, :boolean
    add_column :events, :set_metric, :boolean
  end
end
