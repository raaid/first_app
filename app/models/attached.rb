class Attached < ActiveRecord::Base
  belongs_to :event

  has_attached_file :attached,
  		storage: :s3,
        s3_credentials: "#{Rails.root}/config/s3.yml",
        path: "/attached/:style/:basename.:extension"

  validates_attachment_size :attached, :less_than => 5.megabytes
  randomizes_attachment_file_name :attached

  def attached_url(style)
    if attached_file_name
      attached.url(style)
    end
  end
end
