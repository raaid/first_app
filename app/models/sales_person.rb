class SalesPerson < ActiveRecord::Base
  #attr_accessible :avatar_content_type, :avatar_file_name, :avatar_file_size, :email, :fname, :lname
  validates :email, uniqueness: true


   has_attached_file :avatar,
                    :styles => {:newsfeed => ["100x100#", :jpg],
                                :profile => ["200x200#", :jpg],
                                :mobile => ["50x50#", :jpg]},
                    :default_url => '/images/avatar/:style/missing.jpg',
                    storage: :s3,
                    s3_credentials: "#{Rails.root}/config/s3.yml",
                    path: "/avatar/:style/:filename"
  randomizes_attachment_file_name :avatar
#  validates_attachment_size :avatar, less_than: 5.megabytes
  validates_attachment_content_type :avatar, content_type: /image/


  def avatar_url(style)
    # If an avatar exists, use that, else return a default.
    if avatar_file_name
      avatar.url(style)
    else
      "/images/avatar/#{style}/missing.jpg"
    end
  end

  def display_name
    has_fname = fname && fname.length > 0
    has_lname = lname && lname.length > 0

    if has_fname && has_lname
      "#{fname} #{lname}"
    elsif has_fname
      fname
    elsif has_lname
      lname
    else
      "Mysterious Stranger"
    end
  end
end
