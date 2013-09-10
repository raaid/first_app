class Wallpaper < ActiveRecord::Base
	belongs_to :event

   has_attached_file :wallpaper,
                    :pre_convert_options => { :all => '-auto-orient' },   
                    :styles => {:background => ["1950x900#", :jpg], :preview => ["130x60#", :jpg]},
                    :default_url => '/images/wallpaper/:style/missing.jpg',
                    storage: :s3,
                    s3_credentials: "#{Rails.root}/config/s3.yml",
                    path: "/wallpaper/:style/:filename"

  validates_attachment_content_type :wallpaper, content_type: /image/
  randomizes_attachment_file_name :wallpaper

  def wallpaper_url(style)
    if wallpaper_file_name
      wallpaper.url(style)
    end
  end

  #def wallpaper=(event_poster)
  #  self.wallpaper.assign wallpaper.tempfile
  #end
end
