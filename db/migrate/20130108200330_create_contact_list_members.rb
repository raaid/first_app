class CreateContactListMembers < ActiveRecord::Migration
  def change
    create_table :contact_list_members do |t|
      t.string :name
      t.string :email
      t.references :user
      t.references :contact_list

      t.timestamps
    end
    add_index :contact_list_members, :user_id
    add_index :contact_list_members, :contact_list_id
  end
end
