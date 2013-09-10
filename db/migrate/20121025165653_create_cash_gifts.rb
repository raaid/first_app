class CreateCashGifts < ActiveRecord::Migration
  def change
    create_table :cash_gifts do |t|
      t.string :title
      t.decimal :amount
      t.string :status
      t.string :guest_email
      t.string :guest_name
      t.integer :guest_id
      t.references :user
      t.string :paypal_transaction_id
      t.text :message
      t.integer :payout_fee_transaction_id
      t.integer :payout_user_transaction_id
      t.integer :cashgifttype_id
      t.string :currency
      t.boolean :privacy
      t.boolean :fee_charged


      t.timestamps
    end
  end
end
