class CreatePaypalTransactions < ActiveRecord::Migration
  def change
    create_table :paypal_transactions do |t|
      t.decimal :amount
      t.string :from
      t.string :to
      t.text :response
      t.string :paypal_transaction_id

      t.timestamps
    end
  end
end
