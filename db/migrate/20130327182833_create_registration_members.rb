class CreateRegistrationMembers < ActiveRecord::Migration
  def change
    create_table :registration_members do |t|
      t.references  :registration_list
      t.string :name
      t.string :email
      t.text :message
      t.timestamps
    end
  end
end
