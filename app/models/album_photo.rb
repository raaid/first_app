class AlbumPhoto < ActiveRecord::Base
  #attr_accessible :album_id, :album_photo_content_type, :album_photo_file_name, :album_photo_file_size, :caption
  belongs_to :album

  include Rails.application.routes.url_helpers

  has_attached_file :album_photo,
                    :pre_convert_options => { :all => '-auto-orient' },  
                    :styles => {:display => ["1950x", :jpg],  #set width to 1950px, dynamic height
                                :zoomed => ["450x450#", :jpg],
                  							:cover => ["150x150#", :jpg],
                								:mobile => ["50x50#", :jpg]},
                    :default_url => '/album_photo/:style/missing.jpg',
                    storage: :s3,
                    s3_credentials: "#{Rails.root}/config/s3.yml",
                    path: "/album_photo/:style/:filename"
  randomizes_attachment_file_name :album_photo

  #validates_attachment_size :album_photo, less_than: 2.megabytes
  validates_attachment_content_type :album_photo, content_type: /image/

  def photo_url(style)
    if album_photo_file_name
      album_photo.url(style)
    end
  end

  def to_jq_upload
    {
      "name" => read_attribute(:album_photo_file_name),
      "size" => read_attribute(:album_photo_file_size),
      "url" => album_photo.url(:original),
      "delete_url" => album_photo_path(self),
      "delete_type" => "DELETE" 
    }
  end
end
