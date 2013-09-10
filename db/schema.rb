# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130829193752) do

  create_table "album_photos", :force => true do |t|
    t.string   "album_photo_file_name"
    t.string   "album_photo_content_type"
    t.integer  "album_photo_file_size"
    t.string   "caption"
    t.integer  "album_id"
    t.integer  "approved"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "albums", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "event_id"
    t.integer  "private"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "attacheds", :force => true do |t|
    t.integer  "event_id"
    t.string   "attached_file_name"
    t.string   "attached_content_type"
    t.string   "attached_file_size"
    t.string   "name"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "token"
    t.string   "secret"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "authentications", ["user_id"], :name => "index_authentications_on_user_id"

  create_table "cash_gifts", :force => true do |t|
    t.string   "title"
    t.decimal  "amount"
    t.string   "status"
    t.string   "guest_email"
    t.string   "guest_name"
    t.integer  "guest_id"
    t.integer  "user_id"
    t.string   "paypal_transaction_id"
    t.text     "message"
    t.integer  "payout_fee_transaction_id"
    t.integer  "payout_user_transaction_id"
    t.integer  "cashgifttype_id"
    t.string   "currency"
    t.boolean  "privacy"
    t.boolean  "fee_charged"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "cashgifttypes", :force => true do |t|
    t.integer  "user_id"
    t.text     "description"
    t.string   "cgp_file_name"
    t.string   "cgp_content_type"
    t.string   "cgp_file_size"
    t.boolean  "shown"
    t.decimal  "goal"
    t.string   "title"
    t.string   "currency"
    t.boolean  "privacy"
    t.boolean  "is_donation"
    t.integer  "event_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "comments", :force => true do |t|
    t.integer  "event_id"
    t.text     "message"
    t.integer  "user"
    t.string   "email"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "contact_list_members", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.integer  "user_id"
    t.integer  "contact_list_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "contact_list_members", ["contact_list_id"], :name => "index_contact_list_members_on_contact_list_id"
  add_index "contact_list_members", ["user_id"], :name => "index_contact_list_members_on_user_id"

  create_table "contact_lists", :force => true do |t|
    t.string   "name"
    t.integer  "owner_id"
    t.boolean  "admin"
    t.integer  "event_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "contracts", :force => true do |t|
    t.integer  "event_id"
    t.integer  "sales_person_id"
    t.decimal  "commission"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "events", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "address"
    t.string   "city"
    t.string   "province"
    t.string   "country"
    t.string   "postal"
    t.string   "venue_name"
    t.string   "category"
    t.text     "description"
    t.date     "date"
    t.text     "details"
    t.boolean  "has_been_deleted"
    t.boolean  "show_promotor"
    t.boolean  "allow_comments"
    t.boolean  "show_attendees"
    t.boolean  "show_video_message"
    t.boolean  "auto_approve_photos"
    t.boolean  "has_ticketing"
    t.boolean  "has_cash_gifting"
    t.boolean  "has_donations"
    t.boolean  "include_fees"
    t.boolean  "allow_photo_sharing"
    t.boolean  "first_view"
    t.boolean  "use_prem_invites"
    t.boolean  "has_registration"
    t.boolean  "is_private"
    t.text     "cg_message"
    t.string   "event_url"
    t.integer  "max_capacity"
    t.string   "event_image_file_name"
    t.string   "event_image_content_type"
    t.string   "event_image_file_size"
    t.string   "event_poster_file_name"
    t.string   "event_poster_content_type"
    t.string   "event_poster_file_size"
    t.string   "video"
    t.datetime "events"
    t.datetime "startTime"
    t.datetime "datetime"
    t.datetime "endTime"
    t.boolean  "has_youtube"
    t.text     "youtube"
    t.string   "lat"
    t.string   "lon"
    t.boolean  "was_referred"
    t.integer  "referrer"
    t.string   "social_facebook"
    t.string   "social_pinterest"
    t.string   "social_twitter"
    t.string   "social_youtube"
    t.string   "social_website"
    t.string   "social_email"
    t.text     "social_message"
    t.string   "social_hastag"
    t.boolean  "has_social_facebook"
    t.boolean  "has_social_pinterest"
    t.boolean  "has_social_twitter"
    t.boolean  "has_social_youtube"
    t.boolean  "has_social_website"
    t.boolean  "has_social_email"
    t.boolean  "has_social_message"
    t.boolean  "has_social_hastag"
    t.decimal  "attendance_threshold"
    t.string   "url_handle"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.boolean  "set_options"
    t.boolean  "set_tickets"
    t.boolean  "set_donations"
    t.boolean  "set_cg"
    t.boolean  "set_social"
    t.boolean  "set_video"
    t.boolean  "set_photo"
    t.boolean  "set_metric"
    t.integer  "show_attendees_at"
    t.boolean  "set_file"
    t.boolean  "set_sales"
    t.boolean  "set_event_sales"
    t.boolean  "has_videos"
  end

  create_table "invitation_messages", :force => true do |t|
    t.string   "text"
    t.string   "video"
    t.integer  "owner_id"
    t.string   "name"
    t.integer  "event_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "invitation_messages", ["owner_id"], :name => "index_invitation_messages_on_owner_id"

  create_table "invitation_responses", :force => true do |t|
    t.string   "status"
    t.text     "description"
    t.integer  "invitation_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "invitation_responses", ["invitation_id"], :name => "index_invitation_responses_on_invitation_id"

  create_table "invitations", :force => true do |t|
    t.integer  "invited_id"
    t.integer  "invited_to_id"
    t.integer  "owner"
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "invitations", ["invited_id"], :name => "index_invitations_on_invited_id"
  add_index "invitations", ["invited_to_id"], :name => "index_invitations_on_invited_to_id"

  create_table "invited_tos", :force => true do |t|
    t.integer  "last_message_id"
    t.integer  "event_id"
    t.integer  "owner_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "invited_tos", ["event_id"], :name => "index_invited_tos_on_event_id"
  add_index "invited_tos", ["last_message_id"], :name => "index_invited_tos_on_last_message_id"
  add_index "invited_tos", ["owner_id"], :name => "index_invited_tos_on_owner_id"

  create_table "paypal_transactions", :force => true do |t|
    t.decimal  "amount"
    t.string   "from"
    t.string   "to"
    t.text     "response"
    t.string   "paypal_transaction_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "registration_lists", :force => true do |t|
    t.integer  "event_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "registration_members", :force => true do |t|
    t.integer  "registration_list_id"
    t.string   "name"
    t.string   "email"
    t.text     "message"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "sales_people", :force => true do |t|
    t.string   "fname"
    t.string   "lname"
    t.string   "email"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.string   "avatar_file_size"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "thank_yous", :force => true do |t|
    t.string   "to_email"
    t.string   "to_note"
    t.string   "to_name"
    t.string   "opentok_video_id"
    t.integer  "ticket_instance_id"
    t.date     "sent_date"
    t.integer  "sender_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "thank_yous", ["ticket_instance_id"], :name => "index_thank_yous_on_ticket_instance_id"

  create_table "ticket_instances", :force => true do |t|
    t.integer  "ticket_type_id"
    t.integer  "guest_id"
    t.integer  "host_id"
    t.integer  "quantity"
    t.decimal  "price_paid"
    t.string   "guest_email"
    t.string   "guest_name"
    t.string   "paypal_transaction_id"
    t.string   "status"
    t.integer  "event_id"
    t.integer  "payout_fee_transaction_id"
    t.integer  "payout_user_transaction_id"
    t.integer  "payout_affiliate_transaction_id"
    t.string   "currency_paid"
    t.boolean  "fee_charged"
    t.integer  "contract_id"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "ticket_types", :force => true do |t|
    t.integer  "event_id"
    t.decimal  "price"
    t.date     "sell_from"
    t.date     "sell_to"
    t.string   "event_name"
    t.string   "name"
    t.boolean  "groupable"
    t.string   "currency"
    t.boolean  "count_towards_occupancy"
    t.text     "description"
    t.integer  "capacity"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.boolean  "is_deleted"
    t.integer  "group_size"
    t.boolean  "show_remaining"
  end

  create_table "users", :force => true do |t|
    t.integer  "accounttype"
    t.string   "fname"
    t.string   "lname"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.string   "single_access_token"
    t.string   "perishable_token"
    t.date     "birthday"
    t.string   "gender"
    t.string   "address"
    t.string   "city"
    t.string   "province"
    t.string   "country"
    t.string   "postal"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.string   "avatar_file_size"
    t.string   "photourl"
    t.string   "role"
    t.integer  "approve"
    t.string   "businessurl"
    t.string   "cg_key1"
    t.string   "cg_key2"
    t.integer  "referred_by"
    t.boolean  "has_been_referred"
    t.decimal  "negotiated_commission_rate"
    t.integer  "referral_api_key"
    t.boolean  "has_been_deleted"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.integer  "failed_login_count"
    t.integer  "current_login_ip"
    t.integer  "last_login_ip"
  end

  create_table "videos", :force => true do |t|
    t.integer  "event_id"
    t.string   "video"
    t.boolean  "has_youtube"
    t.text     "youtube"
    t.boolean  "default"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "poster_file_name"
    t.string   "poster_content_type"
    t.string   "poster_file_size"
  end

  create_table "wallpapers", :force => true do |t|
    t.integer  "event_id"
    t.string   "wallpaper_file_name"
    t.string   "wallpaper_content_type"
    t.string   "wallpaper_file_size"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  create_table "widget_profiles", :force => true do |t|
    t.string   "tickets_background"
    t.string   "events_background"
    t.integer  "user_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

end
