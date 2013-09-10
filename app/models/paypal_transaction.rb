class PaypalTransaction < ActiveRecord::Base
  attr_accessible :amount, :from, :paypal_transaction_ID, :response, :to, :paypal_transaction_id
end
