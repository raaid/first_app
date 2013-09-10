Ticketacular::Application.routes.draw do
  
  #scope "(:locale)" do

    root to: 'resources#landing_page', via: :get

    resources :wallpapers
    resources :attacheds
    resources :registration_members
    resources :registration_lists
    resources :invitation_responses
    resources :invitation_messages
    resources :contact_lists
    resources :contact_list_members
    resources :discount_codes
    resources :album_photos
    resources :albums
    resources :thank_yous
    resources :paypal_transactions
    resources :ticket_instances
    resources :ticket_types
    resources :events
    resources :authentications
    resource :account, :controller => "users"
    resources :comments
    resources :sessions
    resources :session
    resources :password_resets
    resource :user
    resources :cashgifttypes
    resources :cashgiftsprofiles
    resources :cash_gifts
    resources :sales_people
    resources :contracts
    resources :videos
    resources :social_media
    resources :widget_profiles

    
    mount Resque::Server, at: '/resque'
    
  

  match "sales_index", to: "sales_people#index", as: :sales_index

  match "invited_to/:id", to: "invited_to#show", via: :get
  match "update_cg", to: "events#update_cg"
  match "clone/:id", to: "events#clone", as: :clone_event
  match "is_cloned/:id", to: "events#is_cloned"


  
  match "contact_lists/:id/send_message", to: "contact_lists#send_message", via: :post
  match "contact_lists/:id/import_from_google", to: "contact_lists#import_from_google", via: :get
  match "contact_lists/:id/import_from_facebook", to: "contact_lists#import_from_facebook", via: :get
  match "contact_lists/:id/import_from_apple_mail", to: "contact_lists#import_from_apple_mail", via: :get
  match "contact_lists/:id/import_from_outlook", to: "contact_lists#import_from_outlook", via: :get
  match "contact_lists/:id/google_callback", to: "contact_lists#google_callback", via: :get
  match "contact_lists/:id/import_from_outlook_post", to: "contact_lists#import_from_outlook_post", via: :post
  match "contact_lists/:id/import_from_yahoo_post", to: "contact_lists#import_from_yahoo_post", via: :post
  match "contact_lists/:id/import_from_apple_mail_post", to: "contact_lists#import_from_apple_mail_post", via: :post
  match "delete_list", to: "contact_lists#destroy", as: :delete_list
  
  match "discount_codes/redeem/:id", to: "discount_codes#redeem", via: :get
  match "album_photos/download", to: "album_photos#download", via: :get
  
  match "thank_yous/:id/send", to: "thank_yous#send_thanks_by_id", via: :get
  
  match 'giftcashout',  to: 'cash_gifts#cashout'
  match "gifts_successfully_purchased", to:"cash_gifts#gifts_successfully_purchased"
  match "gifts_error", to:"cash_gifts#gifts_error"
  match "gifts_paid", to: "cash_gifts#gifts_paid", via: :get
  match "cg", to: "cashgifttypes#index", via: :get

  match 'rsvp', to: 'resources#rsvp', via: :get
  match 'pricing', to: 'resources#pricing', via: :get
  match 'blog', to: 'resources#blog', via: :get
  match 'search', to: 'events#find', via: :get



  match "resetpassword", :to => "password_resets#new", as: :new_password_reset
  match "password_resets/create", :to => "password_resets#create", via: :post

  match 'contact', to: 'resources#contact', via: :get, as: :contact
  match 'contact_us', to: 'resources#contact_us', via: :post, as: :contact_us

  match 'terms_of_service', to: 'resources#terms_of_service', via: :get, as: :terms_of_service
  match 'terms_of_service_affiliates', to: 'resources#terms_of_service_affiliates', via: :get, as: :terms_of_service_affiliates


  match "profile",          :to => "users#profile",   :as => :profile
  match "profile/edit",     :to => "users#edit",      :as => :edit_user
  match "profile/update",   :to => "users#edit",      :as => :profile, via: :put
  match "update_user",      :to => "users#update"
  match "destroy_user",     :to => "users#destroy"
  match "dashboard",        :to => "users#dashboard"

  match "login",       :to => "users#new",        :as => :login
  match "create_user", :to => "users#create"
  match "logout",      :to => "sessions#destroy", :as => :logout

  match "search", to: "users#search", via: :post
  match '/search/results', to: 'users#search', via: :post

  match "about", to: "resources#about", via: :get
  match "privacy", to: "resources#privacy", via: :get

  match 'invite_facebook', to: 'authentications#invite_facebook', via: :get
  match 'invite_twitter', to: 'authentications#invite_twitter', via: :get
  match '/auth/:provider/callback' => 'authentications#create'

  match 'landing_page', to: 'resources#landing_page', via: :get

  match 'cashout',  to: 'events#cashout'
  match 'cashout_admin',  to: 'events#cashout_admin'
  match 'test_cashout', to: 'events#test_cashout'

  match "tickets_successfully_purchased", to:"ticket_instances#tickets_successfully_purchased"
  match "tickets_error", to:"ticket_instances#tickets_error"


  match "events_index", to: "events#index"
  match "delete_event", to: "events#destroy"

  match "event/:event_id/ticket_types", to: "ticket_types#index", via: :get, as: :manage_ticket_type
  match "event/:event_id/ticket_types/new", to: "ticket_types#new", as: :ticket_type_new

  match "event/:event_id/ticket/new", to: "ticket_instances#new", via: :get

  match "ticket_instances/:id/redeem", to: "ticket_instances#redeem", via: :get
  match "ticket_instances/resend/:id", to: "ticket_instances#resend", via: :get
  match "ticket_instances/resend/:id", to: "ticket_instances#resend", via: :post, as: :resend
  match "resend_by_email", to: "ticket_instances#resend_by_email"

  match "redeem_ticket", to: "ticket_instances#redeem", via: :post
  match "search_by_email", to: "ticket_instances#search_by_email", via: :get

  match "tickets_paid", to: "ticket_instances#tickets_paid", via: :get

  match "barcode/:id", to: "ticket_instances#barcode", via: :get


  match "albums/:id",         to: "albums#show", as: :album_show
  match "show_albums/:u_id",  to: "albums#index"
  match "delete_album/:id",   to: "albums#destroy"
  match "approve/:id",        to: "album_photos#approve"
  match "update_stream",      to: "album_photos#update_stream"
  match "update_stream2",     to: "album_photos#update_stream2"

    match "checkURL",      to: "events#checkURL"


  match "delete_by_src",      to: "album_photos#delete_by_src"
  match "choose_images",      to: "albums#choose_images"
  match "download_zip",       to: "albums#download_zip", as: :download_zip

  match "albums/:id/destroy", to: "albums#destroy", via: :get

  match "livestream/:id", to: "albums#edit", via: :get
  match "search_events",  to: "events#search"
  match "search_by_date", to: "events#search_by_date"
  match "search_by_city", to: "events#search_by_city"
  match "mobile_search", to: "events#mobile_search"

  match 'howitworks',  to: 'resources#howitworks'
  match 'tools',  to: 'resources#tools'
  match 'affiliates',  to: 'resources#affiliates'
  match 'affiliates_new',  to: 'resources#affiliates_new'
  match 'attendee',  to: 'resources#attendee'



  match 'manage_attached/:e_id', to: 'attacheds#index', as: :manage_attached
  match 'upload_multiple',       to: 'attacheds#upload_multiple'
  match 'add_to_cal/:e_id',      to: 'events#add_to_cal'
  match 'widget_tickets/:e_id',  to: 'events#widget_tickets'
  match 'widget_users/:id',      to: 'events#widget_users'


  match 'add_theme', to: 'wallpapers#add_theme'

  match 'sales_resend', to: 'sales_people#resend'
  match 'sales_forgot',  to: 'sales_people#forgot_link'
  match 'checkSecurityAnswer', to: 'users#checkSecurityAnswer'

  match 'promote/:url_handle',      to: 'events#show'
  match 'new2', to:'events#new2'
  match 'delete_type/:id', to: "ticket_types#destroy"


    match 'landing1',  to: 'resources#landing1'
    match 'landing2',  to: 'resources#landing2'
    match 'landing3',  to: 'resources#landing3'
    match 'landing4',  to: 'resources#landing4'
    match 'landing5',  to: 'resources#landing5'
    match 'landing6',  to: 'resources#landing6'


    #all match links for footer info
  match 'attendees_f', to: 'footerpages#attendee_faq'
  match 'check_in', to: 'footerpages#checkIn'
  match 'concert_planning', to: 'footerpages#concert_planning'
  match 'creators', to: 'footerpages#creator_faq'
  match 'dev_info', to: 'footerpages#dev_info'
  match 'event_ticketing', to: 'footerpages#event_ticketing'
  match 'get_started', to: 'footerpages#getting_started'
  match 'help', to: 'footerpages#help'
  match 'help_guide', to: 'footerpages#help_guide'
  match 'ideas', to: 'footerpages#ideas'
  match 'mobile', to: 'footerpages#mobile'
  match 'money_gifts', to: 'footerpages#money_gifts'
  match 'demo', to: 'footerpages#online_demo'
  match 'online_event', to: 'footerpages#online_event'
  match 'party_planning', to: 'footerpages#party_planning'
  match 'planning_fundraiser', to: 'footerpages#planning_fundraiser'
  match 'pricing_f', to: 'footerpages#pricing'
  match 'privacy', to: 'footerpages#privacy'
  match 'program', to: 'footerpages#program'
  match 'redemption', to: 'footerpages#redemption_info'
  match 'registration_f', to: 'footerpages#registration'
  match 'sales', to: 'footerpages#sales_person'
  match 'sell_tickets_f', to: 'footerpages#sell_tickets'
  match 'post_events_online', to:'footerpages#post_events_online'
  match 'online_event_management', to:'footerpages#online_event_management'
  match 'site_map', to: 'footerpages#site_map'
  match 'submit_feedback', to: 'resources#feedback'
  match 'submit_testimonial', to: 'resources#testimonial'
  match 'terms_of_service', to: 'footerpages#terms'
  match 'testimonials', to: 'footerpages#testimonials'
  match 'upload_photo', to: 'footerpages#upload_photo'
  match 'resend_tickets', to: 'footerpages#resend'
  match 'about_foot', to: 'footerpages#about_foot'

  match 'feedback', to: 'footerpages#feedback'
  match 'gethelp', to: 'footerpages#gethelp'

  match 'consolidated_terms', to: 'resources#consolidated_terms'
  match 'registration_download/:id', to: 'registration_lists#downloadCSV'

#  match '/:locale' => 'resources#landing_page'  #must be last entry in routes.rb
#  end
end