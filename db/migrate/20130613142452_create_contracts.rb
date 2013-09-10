class CreateContracts < ActiveRecord::Migration
  def change
    create_table :contracts do |t|
      t.integer :event_id
      t.integer :sales_person_id
      t.decimal :commission

      t.timestamps
    end
  end
end
