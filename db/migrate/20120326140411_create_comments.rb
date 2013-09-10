class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :event
      t.text :message
      t.integer :user
      t.string :email
      t.string :name
      t.timestamps
    end
  end
end
