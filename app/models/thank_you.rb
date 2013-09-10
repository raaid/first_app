class ThankYou < ActiveRecord::Base
  belongs_to :ticket_instance
  attr_accessible :to_email, :to_name, :to_note, :sent_date, :opentok_video_id, :gift_id, :cash_gift_id, :sender_id
  
  def sender
    User.find(self.sender_id)
  end

  def sent?
    return (self.sent_date != nil)
  end
end
