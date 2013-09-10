class CreateInvitedTos < ActiveRecord::Migration
  def change
    create_table :invited_tos do |t|
      t.references :last_message
      t.references :event
      t.references :owner

      t.timestamps
    end
    add_index :invited_tos, :last_message_id
    add_index :invited_tos, :event_id
    add_index :invited_tos, :owner_id
  end
end
