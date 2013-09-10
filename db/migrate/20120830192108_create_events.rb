class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.references :user
      t.string :name

      t.string :address
      t.string :city
      t.string :province
      t.string :country
      t.string :postal
      t.string :venue_name
      t.string :category

      t.text :description
      t.date :date
      t.text :details
      t.boolean :has_been_deleted
      t.boolean :show_promotor
      t.boolean :allow_comments
      t.boolean :show_attendees
      t.boolean :show_video_message
      t.boolean :auto_approve_photos
      t.boolean :has_ticketing
      t.boolean :has_cash_gifting
      t.boolean :has_donations
      t.boolean :include_fees
      t.boolean :allow_photo_sharing
      t.boolean :first_view
      t.boolean :use_prem_invites
      t.boolean :has_registration
      t.boolean :is_private

      t.text :cg_message

      t.string :event_url
      t.integer :max_capacity

      t.string :event_image_file_name
      t.string :event_image_content_type
      t.string :event_image_file_size

      t.string :event_poster_file_name
      t.string :event_poster_content_type
      t.string :event_poster_file_size

      t.string :video

      t.datetime :events, :startTime, :datetime
      t.datetime :events, :endTime, :datetime

      t.boolean :has_youtube
      t.text :youtube
      t.string :lat
      t.string :lon

      t.boolean :was_referred
      t.integer :referrer

      t.string :social_facebook
      t.string :social_pinterest
      t.string :social_twitter
      t.string :social_youtube
      t.string :social_website
      t.string :social_email
      t.text :social_message
      t.string :social_hastag

      t.boolean :has_social_facebook
      t.boolean :has_social_pinterest
      t.boolean :has_social_twitter
      t.boolean :has_social_youtube
      t.boolean :has_social_website
      t.boolean :has_social_email
      t.boolean :has_social_message
      t.boolean :has_social_hastag

      t.decimal :attendance_threshold
      t.string :url_handle



      t.timestamps
    end
  end
end