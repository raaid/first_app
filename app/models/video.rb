class Video < ActiveRecord::Base
  #attr_accessible :default, :event_id, :has_youtube, :video, :youtube
  has_attached_file :poster,
  					:pre_convert_options => { :all => '-auto-orient' },
                    :styles => {:preview => ["320x240#", :jpg],
								:mobile => ["50x50#", :jpg]},
					#:default_url => 'https://s3.amazonaws.com/storage.production.ticketacular.me/avatar/:style/missing.jpg',
                    storage: :s3,
                    s3_credentials: "#{Rails.root}/config/s3.yml",
                    path: "/poster/:style/:filename"
  randomizes_attachment_file_name :poster
#  validates_attachment_size :avatar, less_than: 5.megabytes
  validates_attachment_content_type :poster, content_type: /image/

  def poster_url(style)
    # If an avatar exists, use that, else return a default.
    if poster_file_name
      poster.url(style)
    else
      #"/images/avatar/#{style}/missing.jpg"
    end
  end

end
