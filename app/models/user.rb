class User < ActiveRecord::Base
  
  has_many :authentications, dependent: :destroy
  GENDER = ["Male", "Female"]
  has_many :events
  has_many :cash_gifts
  has_one :cashgiftsprofile, dependent: :destroy
  has_one :widget_profile, dependent: :destroy


  has_attached_file :avatar,
                    :styles => {:newsfeed => ["100x100#", :jpg],
        :profile => ["200x200#", :jpg],
				:mobile => ["50x50#", :jpg]},:default_url => 'https://s3.amazonaws.com/storage.production.ticketacular.me/avatar/:style/missing.jpg',
                    storage: :s3,
                    s3_credentials: "#{Rails.root}/config/s3.yml",
                    path: "/avatar/:style/:filename"
  randomizes_attachment_file_name :avatar
#  validates_attachment_size :avatar, less_than: 5.megabytes
  validates_attachment_content_type :avatar, content_type: /image/

  validates :fname, presence: true
  validates :email, uniqueness: true

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end

    acts_as_authentic do |c|
    c.session_class = Session
    c.require_password_confirmation = true
    c.merge_validates_format_of_email_field_options unless: Proc.new { |u| u.email.blank? and u.authed? }
    c.merge_validates_length_of_email_field_options unless: Proc.new { |u| u.email.blank? and u.authed? }
    c.merge_validates_length_of_password_field_options unless: Proc.new { |u| u.password.blank? and u.authed? }
    end

  def authed?(provider = nil)
    return (authed?(:twitter) or authed?(:facebook) or authed?(:linkedin)) unless provider
    case provider
    when :twitter  then return self.authentications.find_by_provider("twitter").present?
    when :facebook then return self.authentications.find_by_provider("facebook").present?
    end
  end

def password_required?
  (authentications.empty? || !password.blank?) && super
end

  def self.search(query)
    return [] if query.blank?
    aNameParts = query.split(/ /).map{|sNamePart| "'#{sNamePart.upcase}%'"}
    sQuery = "select a.*, case when upper(lname) like #{aNameParts[aNameParts.length - 1]} and upper(fname) like #{aNameParts[0]} then 0
    when upper(fname) like '#{query.upcase}%' then 0
    when upper(lname) like #{aNameParts[aNameParts.length - 1]} then 1
    when upper(fname) like #{aNameParts[0]} then 2
    else 3 end as relevance from users a where "
    if aNameParts.length >= 1
      sQuery = sQuery + "(UPPER(fname) LIKE #{aNameParts[0]} or UPPER(lname) LIKE #{aNameParts[aNameParts.length - 1]} or UPPER(email) LIKE #{aNameParts[0]} or UPPER(email) LIKE #{aNameParts[aNameParts.length - 1]}"
    end
    self.find_by_sql("#{sQuery})" + " order by relevance, lname, fname")
  end

  def mobile_avatar
    avatar_url(:mobile)
  end

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

  def default_cash_gift_type
    result = Cashgifttype.where({title: "Cash", user_id: id})
    #puts "***** TEST ***** Default: #{result.to_yaml}"
    if result.length > 0 then
      return result[0]
    else
      Cashgifttype.create!({title: "Cash", user_id: id, goal: 1000000, currency: default_currency, shown: true })
    end
  end

  def default_currency
    "CAD"
  end


 before_save do
   # if self.cg_only != FALSE and self.cg_only != TRUE
   #   self.cg_only = FALSE
   # end
 end

  def to_json_hash()
    result = attributes
    result
  end

  def total_ticket_value
     total = 0
     ti = TicketInstance.where(:status=>"paid", :host_id=> id)
     ti.each do |tip|
       total = total +tip.amount
     end
     ti2 = TicketInstance.where(:status=>"redeemed", :host_id=> id)
          ti2.each do |tir|
            total = total +tir.amount
          end
     total
  end

 end
