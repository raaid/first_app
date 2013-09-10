class CreateInvitationMessages < ActiveRecord::Migration
  def change
    create_table :invitation_messages do |t|
      t.string :text
      t.string :video
      t.references :owner
      t.string :name
      t.integer :event_id


      t.timestamps
    end
    add_index :invitation_messages, :owner_id
  end
end
