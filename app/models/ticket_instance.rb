class TicketInstance < ActiveRecord::Base
  #attr_accessible :guest, :guest_id, :guest_email, :guest_name, :host_id, :paypal_transaction_id, :price_paid, :quantity, :status, :ticket_type, :ticket_type_id, :currency_paid, :event_id

  def ticket_type
    TicketType.find(ticket_type_id)
  end

  def event
    ticket_type.event
  end

  def host
    User.find(host_id)
  end

  def event_id
    ticket_type.event_id
  end

  def event_name
    ticket_type.event_name
  end

  def cashout_fee
    # The fee for the ticket is 2.5% of the total, plus a per-ticket amount dependent on the amount of the ticket itself.
    per_ticket_cost = case (price_paid / quantity)
                        when 0..0.99 then 0
                        when 1..4.99 then 0.25
                        when 5..9.99 then 0.5
                        when 10..19.99 then 0.75
                        else 0.99
                      end
                        
    ticket_cost = (price_paid * 0.025) + (per_ticket_cost * quantity)
  end

  validates :guest_email, presence: true
  validates :guest_name, presence: true
end
