class CashGift < ActiveRecord::Base
  attr_accessible :amount, :guest_email, :guest_id, :guest_name, :message, :payout_fee_transaction_id, :payout_user_transaction_id, :paypal_transaction_id, :status, :title, :user_id, :cashgifttype_id, :currency, :privacy
  belongs_to :user
  validates :currency, presence: true
  validates :guest_email, presence: true
  validates :amount, presence: true
  validates :guest_name, presence: true

  def cashout_fee
    amount * 0.025
  end
end
