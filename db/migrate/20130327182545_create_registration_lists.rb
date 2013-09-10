class CreateRegistrationLists < ActiveRecord::Migration
  def change
    create_table :registration_lists do |t|
      t.references :event

      t.timestamps
    end
  end
end
