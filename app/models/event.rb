class Event < ActiveRecord::Base
  belongs_to :user
  has_many :comment, dependent: :destroy
  has_many :wallpaper
  has_one :album
  has_one :registration_list

  geocoded_by :geocoder, :latitude  => :lat, :longitude => :lon
  after_validation :geocode

  #validates :url_handle, uniqueness: true


  CATEGORY_PERSONAL = "Personal"
  CATEGORY_ENTERTAINMENT = "Entertainment"
  CATEGORY_CHARITY = "Charity"
  CATEGORY_BUSINESS = "Business"


  has_attached_file :event_image,
                    :styles => {:standard => ["500x500#", :jpg],:feed => ["275x275#", :jpg]},
                    :default_url => '/images/event_image/:style/missing.jpg',
                    storage: :s3,
                    s3_credentials: "#{Rails.root}/config/s3.yml",
                    path: "/event_image/:style/:filename"

  has_attached_file :event_poster,
                    :styles => {:background => ["1950x900#", :jpg], :preview => ["130x60#", :jpg]},
                    :default_url => '/images/event_poster/:style/missing.jpg',
                    storage: :s3,
                    s3_credentials: "#{Rails.root}/config/s3.yml",
                    path: "/event_poster/:style/:filename"

  validates_attachment_content_type :event_image, content_type: /image/
  validates_attachment_content_type :event_poster, content_type: /image/
  validate :validate_end_date_before_start_date

  def validate_end_date_before_start_date
    if startTime && endTime
      errors.add("end time", "must be greater than start date") if endTime < startTime
    end
  end

  def geocoder
    [address, city, province, country].compact.join(', ')
  end

  def ticket_types
    TicketType.find_all_by_event_id(id)
  end

  def event_url(style)
    if event_image_file_name
      event_image.url(style)
    end
  end

  def event_poster_url(style)
    if event_poster_file_name
      event_poster.url(style)
    end
  end

  def self.search(query)
      return []
  end

#  def event_image=(event_image)
#      self.event_image.assign event_image.tempfile
#  end

  def event_poster=(event_poster)
      self.event_poster.assign event_poster.tempfile
    end
end
