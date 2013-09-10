class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :accounttype
      t.string :fname
      t.string :lname
      t.string :email
      t.string :crypted_password
      t.string :password_salt
      t.string :persistence_token
      t.string :single_access_token
      t.string :perishable_token
      t.date :birthday
      t.string :gender
      t.string :address
      t.string :city
      t.string :province
      t.string :country
      t.string :postal

      t.string :avatar_file_name
      t.string :avatar_content_type
      t.string :avatar_file_size
      t.string :photourl
      t.string :role
      t.integer :approve
      t.string :businessurl

      t.string :cg_key1
      t.string :cg_key2

      t.integer :referred_by
      t.boolean :has_been_referred
      t.decimal :negotiated_commission_rate
      t.integer :referral_api_key

      t.boolean :has_been_deleted

      t.datetime :created_at
      t.datetime :updated_at
      t.datetime :last_request_at
      t.datetime :last_login_at
      t.datetime :current_login_at
      t.integer :failed_login_count
      t.integer :current_login_ip
      t.integer :last_login_ip
      t.timestamps
    end
  end
end
