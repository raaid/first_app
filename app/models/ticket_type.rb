class TicketType < ActiveRecord::Base
 # attr_accessible :event, :event_id, :event_name, :groupable, :name, :price, :sell_from, :sell_to, :currency

  validates :name, presence: true
  validates :price, presence: true
  validates :sell_from, presence: true
  validates :sell_to, presence: true
  validate :validate_end_date_before_start_date

  def validate_end_date_before_start_date
    if sell_to && sell_from
      errors.add("end date", "must be greater than start date") if sell_to < sell_from
    end
  end
end
