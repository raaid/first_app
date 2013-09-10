class CreateThankYous < ActiveRecord::Migration
  def change
    create_table :thank_yous do |t|
      t.string :to_email
      t.string :to_note
      t.string :to_name
      t.string :opentok_video_id
      t.references :ticket_instance
      t.date  :sent_date
      t.integer :sender_id
      t.timestamps
    end
    add_index :thank_yous, :ticket_instance_id
  end
end
