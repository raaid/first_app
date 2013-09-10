class CreateTicketTypes < ActiveRecord::Migration
  def change
    create_table :ticket_types do |t|
       t.references :event
       t.decimal :price
       t.date :sell_from
       t.date :sell_to
       t.string :event_name
       t.string :name
       t.boolean :groupable
       t.string :currency
       t.boolean :count_towards_occupancy

       t.text :description
       t.integer :capacity
       t.timestamps
    end
  end
end
