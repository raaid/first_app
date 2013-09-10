class CreateWidgetProfiles < ActiveRecord::Migration
  def change
    create_table :widget_profiles do |t|
      t.string :tickets_background
      t.string :events_background
      t.integer :user_id

      t.timestamps
    end
  end
end
