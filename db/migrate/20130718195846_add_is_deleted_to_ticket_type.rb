class AddIsDeletedToTicketType < ActiveRecord::Migration
  def change
    add_column :ticket_types, :is_deleted, :boolean
  end
end
