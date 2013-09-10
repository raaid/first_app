class AddShowRemainingToTicketTypes < ActiveRecord::Migration
  def change
    add_column :ticket_types, :show_remaining, :boolean
  end
end
