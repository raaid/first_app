class Cashgifttype < ActiveRecord::Base
  attr_accessible :cgp,:cgp_content_type, :cgp_file_name, :cgp_file_size, :description, :goal, :shown, :title, :user_id, :currency, :event_id, :is_donation
  belongs_to :user
  validates :currency, presence: true
  #validates :goal, presence: true
  validates :title, presence: true

  has_attached_file :cgp,
                       :styles => {:newsfeed => ["100x100#", :jpg],
                                   :thumb => ["40x40#", :jpg],
                                   :mobile => ["50x50#", :jpg]}, :default_url => '/images/cgp/:style/missing.jpg',
                       storage: :s3,
                       s3_credentials: "#{Rails.root}/config/s3.yml",
                       path: "/cgp/:style/:filename"
     randomizes_attachment_file_name :cgp
   #  validates_attachment_size :photo, less_than: 5.megabytes
     validates_attachment_content_type :cgp, content_type: /image/

   def mobile_photo
       if cgp_file_name
         cgp.url(:mobile)
       end
     end

   def self.default_cgp_url(style)
     "/images/cgp/#{style}/missing.jpg"
   end

   def cgp_url(style)
     # If a photo exists, use that, else return a default.
     if cgp_file_name
       cgp.url(style)
     else
       Cashgifttype::default_cgp_url(style)
     end
   end

   def is_default_cash_gift
     # We decided to match using the title. A bug could occur if a gift is manually added with this title, but we predict it would be minor and unlikely to occur in practice.
     title == default_cash_gift_title
   end

   def default_cash_gift_title
     "Cash"
   end

   # The default cash gift cannot be edited or destroyed.
   def is_editable
     not is_default_cash_gift
   end

   # The default cash gift cannot be edited or destroyed.
   def is_deletable
     not is_default_cash_gift
   end
 end
