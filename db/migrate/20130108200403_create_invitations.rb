class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.references :invited
      t.references :invited_to
      t.integer :owner
      t.string :name
      t.string :email
      t.timestamps
    end
    add_index :invitations, :invited_id
    add_index :invitations, :invited_to_id
  end
end
