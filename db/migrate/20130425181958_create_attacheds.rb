class CreateAttacheds < ActiveRecord::Migration
  def change
    create_table :attacheds do |t|
      t.integer :event_id
      t.string :attached_file_name
      t.string :attached_content_type
      t.string :attached_file_size
      t.string :name


      t.timestamps
    end
  end
end
