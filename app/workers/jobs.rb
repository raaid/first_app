module Jobs
	class Clone
		@queue = :clone_queue
		def self.perform(id)
		#	puts 'CLONING EVENT'
			@original = Event.find(id)    
		
    		@event = Event.new(@original.attributes)

	    	@event.has_been_deleted = false
    		@event.first_view = true
    		if @event.save
    			@event.url_handle = @event.id
    			@event.save
            	@album = Album.new(:event_id=>@event.id, :name=>@event.name, :private=>0)
            	@album.save
            	@registration_list = RegistrationList.new(:event_id=>@event.id)
            	@registration_list.save
    	        @contact_list = ContactList.new(:event_id=>@event.id,:admin=>true, :name=>"List of Ticket Purchasers",:owner_id=>@event.user_id)
	           	@contact_list.save
        	    @wallpapers = Wallpaper.find_all_by_event_id(id)
            	@wallpapers.each do |paper|
              		newPaper = Wallpaper.new(:event_id => @event.id, :wallpaper => paper.wallpaper)
              		newPaper.save
            	end
            	@ticket_types = TicketType.where(:event_id => @original.id, :is_deleted => false)
            	@ticket_types.each do |type|
              		type.event_id = @event.id
              		ticket_type = TicketType.new(type.attributes)
              		ticket_type.save
            	end
            	@cashgifttypes = Cashgifttype.where(:event_id => @original.id)
            	@cashgifttypes.each do |type|
              		type.event_id = @event.id
              		giftType = Cashgifttype.new(type.attributes)
              		giftType.save
            	end
            	@attacheds = Attached.where(:event_id => @original.id)
            	@attacheds.each do |attached|
              		att = Attached.new(event_id: @event.id, attached: attached.attached, name: attached.name)
              		att.save
            	end
            	@videos = Video.where(event_id: @original.id)
	            @videos.each do |video|
    		        vid = Video.new(event_id: @event.id, video: video.video, has_youtube: video.has_youtube, youtube: video.youtube, default: video.default, poster: video.poster)
            		vid.save
            	end
    		end
    	#	puts 'CLONING FINISHED'
		end
		def self.after_perform(id)
			puts 'FINISHED!'
		end
	end

  class Resend_by_email
    @queue = :resend_by_email_queue
    def self.perform(id)
      puts 'RESEND BY EMAIL'
      @ticket_instance = TicketInstance.find(id)
      @tickets = TicketInstance.where("guest_email = ? and (status = ? or status = ?)", @ticket_instance.guest_email, "paid", "redeemed")

      Notifier.deliver_ticket_purchase_email(@tickets)
      puts 'FINISHED RESENDING'
    end
  end

  class Resend
    @queue = :resend_queue
    def self.perform(id)
      puts 'RESEND TICKETS'
      @ticket_instance = TicketInstance.find(id)
      @tickets = TicketInstance.where(:guest_email => @ticket_instance.guest_email, :ticket_type_id => @ticket_instance.ticket_type_id)

      Notifier.deliver_ticket_purchase_email(@tickets)
      puts 'FINISHED RESENDING'
    end
  end

  class Sales_person_invite
    @queue = :mailer_queue
    def self.perform(id, event_id)
      puts 'INVITE SALES PERSON'
      @sales_person = SalesPerson.find(id)    

      secret = Digest::SHA1.hexdigest("Kzgg4cb9hThp7zSwL3Ta")
      a = ActiveSupport::MessageEncryptor.new(secret)
      link = "http://www.eventastic.com/sales_people/" + @sales_person.id.to_s + "?pass=" + CGI::escape(a.encrypt_and_sign(@sales_person.email))

      owner_name = User.find(Event.find(event_id).user_id).display_name

      Notifier.sales_person_invite(@sales_person, owner_name, link).deliver
      puts 'FINISHED INVITING'
    end
  end

  class Deliver_invitation_message_email
    @queue = :mailer_queue
    def self.perform(id, message_id)
      list = ContactList.find(id)
      message = InvitationMessage.find(message_id)
      event_id = nil

      list.contact_list_members.each do |member|
        # Only create an invite if one doesn't exist, and only send a message if a response has not been received.
        invitation = Invitation.where({invited_id: member.id, invited_to_id: event_id}).first
        if invitation
          existing_invitation_response = InvitationResponse.where({invitation_id: invitation.id}).first
        else
          invitation = Invitation.create!(:invited_id=> member.id, :invited_to_id=> event_id, :owner=> current_user.id, :email=>member.email, :name=>member.name)
          invitation_response = InvitationResponse.create!(:invitation_id=> invitation.id)
        end

        if not existing_invitation_response
          Notifier.deliver_invitation_message_email(invitation, message, member)
        end
      end
      puts 'FINISHED'
    end
  end

  class Deliver_invitation_message_email
    @queue = :mailer_queue
    def self.perform(id)
      thanks = ThankYou.find(id)
      Notifier.deliver_thank_you_email(thanks)
      puts 'FINISHED'
    end
  end

  class Deliver_ticket_purchase_email
    @queue = :mailer_queue
    def self.perform(successes)
      Notifier.deliver_ticket_purchase_email(successes)
      puts 'FINISHED'
    end
  end

  class Tickets_paid
    @queue = :tickets_queue
    def self.perform(paypal_token, paid_ticket_ids, ip)
      paypal_details = EXPRESS_GATEWAY.details_for(paypal_token)

      total_price = 0
      currency = 'CAD'
      paid_tickets = []
      paid_ticket_ids = paid_ticket_ids.split('-')
      fees_included = true
      for paid_ticket_id in paid_ticket_ids do
        paid_ticket = TicketInstance.find(paid_ticket_id)
        paid_ticket.status = 'paid'
        paid_tickets << paid_ticket
        total_price += (paid_ticket.price_paid * 100)
        currency = paid_ticket.currency_paid

        event = Event.where(:id => paid_ticket.event_id ).first
        unless event.include_fees == true
          fees_included = false
        end
      end

      if fees_included
        
        total_price += ((total_price * 0.029) + 30).to_i
      end

      purchase = EXPRESS_GATEWAY.purchase(total_price,
                                        :ip       => ip,
                                        :payer_id => paypal_details.payer_id,
                                        :token    => paypal_token,
                                        :currency => currency,
                                        :description => 'Purchase From Eventastic'
      )

      paypal_transaction_id = paypal_token

      if !purchase.success? and FALSE
      #  @message = purchase.message
        # This action doesn't exist - where is a good place to redirect? Probably back to the "buy tickets" page.
      #  redirect_to tickets_error_path
      #  return
      else
        @contact_list
        reg_email = ''
        reg_name = ''

        for paid_ticket in paid_tickets do
          paid_ticket.paypal_transaction_id = paypal_transaction_id
          if fees_included == true
              paid_ticket.fee_charged = true
          else
              paid_ticket.fee_charged = false
          end
          paid_ticket.save!
          @contact_list = ContactList.where(:admin => true, :event_id => paid_ticket.event_id).first
          @contact_list_member = ContactListMember.new(:contact_list_id=>@contact_list.id,:name=>paid_ticket.guest_name, :email=>paid_ticket.guest_email, :user_id=>paid_ticket.host_id)
          @contact_list_member.save
          reg_name = paid_ticket.guest_name
          reg_email = paid_ticket.guest_email
        end

        @registration_member = RegistrationMember.new
        @registration_member.name = reg_name
        @registration_member.email = reg_email
        @registration_member.registration_list_id = event.id
        @registration_member.save

        Notifier.deliver_ticket_purchase_email(paid_tickets)

        owner = User.find(event.user_id)
        Notifier.notify_ticket_sale(owner, paid_tickets[0], event).deliver
      end
    end
  end
end