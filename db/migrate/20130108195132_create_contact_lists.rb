class CreateContactLists < ActiveRecord::Migration
  def change
    create_table :contact_lists do |t|
      t.string :name
      t.references :owner
      t.boolean :admin
      t.integer :event_id

      t.timestamps
    end
  end
end
