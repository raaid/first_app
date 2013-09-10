class CreateCashgifttypes < ActiveRecord::Migration
  def change
    create_table :cashgifttypes do |t|
      t.references :user
      t.text :description
      t.string :cgp_file_name
      t.string :cgp_content_type
      t.string :cgp_file_size
      t.boolean :shown
      t.decimal :goal
      t.string :title
      t.string :currency
      t.boolean :privacy
      t.boolean :is_donation
      t.integer :event_id

      t.timestamps
    end
  end
end
