class CreateAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.references :user
      t.string :provider
      t.string :uid
      t.string :token
      t.string :secret

      t.timestamps
    end
    add_index :authentications, :user_id
  end
end
