class CreateInvitationResponses < ActiveRecord::Migration
  def change
    create_table :invitation_responses do |t|
      t.string :status
      t.text :description
      t.references :invitation

      t.timestamps
    end
    add_index :invitation_responses, :invitation_id
  end
end
