class CreateSalesPeople < ActiveRecord::Migration
  def change
    create_table :sales_people do |t|
      t.string :fname
      t.string :lname
      t.string :email
      t.string :avatar_file_name
      t.string :avatar_content_type
      t.string :avatar_file_size

      t.timestamps
    end
  end
end
