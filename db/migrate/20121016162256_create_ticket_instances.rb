class CreateTicketInstances < ActiveRecord::Migration
  def change
    create_table :ticket_instances do |t|
       t.references :ticket_type
       t.references :guest
       t.references :host
       t.integer :quantity
       t.decimal :price_paid
       t.string :guest_email
       t.string :guest_name
       t.string :paypal_transaction_id
       t.string :status

       t.integer :event_id
       t.integer :payout_fee_transaction_id
       t.integer :payout_user_transaction_id
       t.integer :payout_affiliate_transaction_id
       t.string  :currency_paid
       t.boolean :fee_charged

       t.integer :contract_id


       t.timestamps
     end
  end
end
