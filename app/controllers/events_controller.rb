require 'active_support/core_ext'
require 'resque'

class EventsController < ApplicationController

  before_filter :mobilize
  before_filter :require_user, :only => [:index, :new, :create, :edit]
  respond_to :html, :js, :mobile, :json

  layout :resolve_layout
  #layout 'event_page', only: [:show]
  #layout 'widget_tickets', only: [:widget_tickets]

  TICKET_STATUS_UNPAID = "unpaid"
  TICKET_STATUS_PAID = "paid"
  TICKET_STATUS_REFUNDED = "refunded"
  TICKET_STATUS_REDEEMED = "redeemed"

  CASHGIFT_STATUS_UNPAID = "unpaid"
  CASHGIFT_STATUS_PAID = "paid"
  CASHGIFT_STATUS_REFUNDED = "refunded"

  def index
    @events = Event.where(:user_id => current_user.id, :has_been_deleted => false)
    @event = Event.new
    @event.max_capacity = 0
    @event.allow_comments = true
    @event.auto_approve_photos = false
    @event.show_promotor = true
    @event.show_video_message = false
    @event.show_attendees = false
    @event.include_fees = false
    @event.show_attendees = true
    @event.first_view = true
    @event.has_been_deleted = false
    @event.has_registration = false
    @event.is_private = false
    @event.has_youtube = false
    @event.category = Event::CATEGORY_PERSONAL

    @all_wallpapers = []
    @events.each do |event|
      @all_wallpapers << Wallpaper.where(:event_id=>event.id)
    end
    

    respond_to do |format|
      format.html # index.html.erb
      format.mobile # index.mobile.erb
      format.json { render json: @events }
    end
  end

  def show
      if params[:url_handle]
        @event = Event.where(:url_handle => params[:url_handle]).first
      else
        @event = Event.where(:id => params[:id]).first
      end
      if @event

      @owner = User.find(@event.user_id)
      @ownerMD5 = Digest::MD5.hexdigest(@owner.email)
      @user = @owner
      @capacity = 0
      @quantities = []
      @hasApprovedPhotos = 0

      @all_wallpapers = Wallpaper.where(:event_id=>@event.id)
      @album = Album.where(:event_id =>@event.id).first
      @registration_list = RegistrationList.where(:event_id =>@event.id).first
      @cgs = Cashgifttype.where(:event_id => @event.id, :shown => true)
      @documents = Attached.find_all_by_event_id(@event.id)
      @tickettypes = @event.ticket_types
      @comments = Comment.where(:event_id=> @event.id)
      @registration_members = RegistrationMember.where(:registration_list_id =>@registration_list.id)
      @photos = AlbumPhoto.find_all_by_album_id(@album.id)

      @album_photo = AlbumPhoto.new(:album_id => @album.id.to_i, :approved=> 0)
      @registration_member = RegistrationMember.new(:registration_list_id => @registration_list.id)
      @comment = Comment.new(:event_id => @event.id)
      @cash_gift = CashGift.new(:guest_email => current_user ? current_user.email : "",:guest_name => current_user ? current_user.display_name : "",:status => CASHGIFT_STATUS_UNPAID,:user_id => @event.user_id)
      @ticket_instance = TicketInstance.new(:guest_email => current_user ? current_user.email : "",:guest_name => current_user ? current_user.display_name : "",:status => TICKET_STATUS_UNPAID,:host_id => @event.user_id  )

      @cashgifttypes = @cgs.where(:is_donation => false)
      @donations = @cgs.where(:is_donation => true)
      @tickets = @tickettypes
      @cash_description = @event.cg_message      

      if current_user then
        @comment.user = current_user.id
        @cash_gift.guest_id = current_user.id
        @ticket_instance.guest_id = current_user.id
      end

      @photos.each do |photo|
        if photo.approved == 1
          @hasApprovedPhotos = 1
          break
        end
      end
      @comments.each do |comment|
        md5 = Digest::MD5.hexdigest(comment.email)
        comment['md5'] = md5
      end
     # @video_html = false
      if @event.has_videos
        @videos = Video.find_all_by_event_id(@event.id)
        @opentokVideos = []
        @youtubeVideos = []
        @videos.each do |video|
          if video.has_youtube
            @youtubeVideos << {yt: video.youtube.split('/').last, id: video.id}
          else
            @opentokVideos << {url: opentok_mp4_url(video.video), id: video.id, poster: video.poster_url(:preview)}
          end
          if video.default
            @featuredVideo = video
          end
        end
      #  @videos = opentok_video_html2(@event.video)
      end

      if params[:refer]
        cookies[:event_id] = {:value => @event.id, :expires => 1.year.from_now}
        cookies[:contract_id] = {:value => params[:refer], :expires => 1.year.from_now}
      end

         @event.ticket_types.each do |ticket_type|
            if ticket_type.sell_to > Date.today

              max_count = 0
              if ticket_type.capacity
                if ticket_type.capacity > 0
                  @instances = TicketInstance.find_all_by_ticket_type_id(ticket_type.id)
                
                  @instances.each do |ticket|
                    max_count += ticket.quantity
                  end
                end
              end

              @quantities << { ticket_type: ticket_type, max_count: max_count, count_towards_occupancy: ticket_type.count_towards_occupancy }
            end

          if @event.max_capacity
            if @event.max_capacity > 0
              if ticket_type.count_towards_occupancy
                tickets = TicketInstance.where("ticket_type_id = ? and (status = 'paid' or status = 'redeemed')", ticket_type.id)
                tickets.each do |ticket|
                  @capacity += ticket.quantity * ticket_type.group_size
                end
              end
            end
          end
         end

         @tickets = TicketInstance.find_all_by_event_id(@event.id)
         @lists = RegistrationList.find_all_by_event_id(@event.id)

         @attendees = []

        if @event.has_ticketing
         @tickets.each do |ticket|
          if ticket.status == "paid" or ticket.status == "redeemed"
            checker = @attendees.detect {|f| f[:email] == ticket.guest_email }
            unless checker

              is_gravatar = 1
              @user = User.find_by_email(ticket.guest_email)
              data = ""

              if @user
                if @user.avatar_file_name

                  data = @user.avatar_url(:newsfeed)
                  is_gravatar = 0
                else
                  data = Digest::MD5.hexdigest(@user.email)
                end
              else
                data = Digest::MD5.hexdigest(ticket.guest_email)
              end

             # puts ticket.guest_name
              #image_data is either the image_url or email md5 depending on if we're using gravatar or user avatar
              @attendees << {:name => ticket.guest_name, :email => ticket.guest_email, :image_data => data, :is_gravatar => is_gravatar }
            end
           end
         end
        end

        if @event.has_registration
         @lists.each do |list|
          @members = RegistrationMember.find_all_by_registration_list_id(list.id)
          @members.each do |member|
            checker = @attendees.detect {|f| f[:email] == member.email }
            unless checker

              is_gravatar = 1
              @user = User.find_by_email(member.email)
              data = ""

              if @user
                if @user.avatar_file_name

                  data = @user.avatar_url(:newsfeed)
                  is_gravatar = 0
                else
                  data = Digest::MD5.hexdigest(@user.email)
                end
              else
                data = Digest::MD5.hexdigest(member.email)
              end
              @attendees << {:name => member.name, :email => member.email, :image_data => data, :is_gravatar => is_gravatar}
            end
          end
         end
       end

    #  @show_tutorial = false
      if @event.first_view
      #@show_tutorial = true
      @event.first_view = false
      @event.save
      end

     # @show_cg_tutorial = false
     # @show_donation_tutorial = false
     # @show_ticketing_tutorial = false


     # if @event.has_cash_gifting
     #   unless Cashgifttype.where(:event_id => @event.id, :is_donation => false).count > 0
     #   @show_tutorial = true
     #   @show_cg_tutorial = true
     #   end
     # end
     # if @event.has_donations
     #   unless Cashgifttype.where(:event_id => @event.id, :is_donation => true).count > 0
     #   @show_tutorial = true
     #   @show_donation_tutorial = true
     #   end
     # end
     # if @event.has_ticketing
     #   unless TicketType.where(:event_id => @event.id).count >0
     #   @show_tutorial = true
     #   @show_ticketing_tutorial = true
     #   end
     # end
     # if @all_wallpapers.empty?
     #   @show_tutorial = true
     # end


     # unless current_user && current_user.id == @event.user_id
     #   @show_tutorial = false
     # end
      respond_to do |format|
        format.html # show.html.erb
        format.mobile # show.html.erb
        format.json { render json: @event }
      end
      else
        respond_to do |format|
          format.html  {redirect_to root_path, alert: 'That Event Was Not Found!'}
          format.mobile # show.html.erb
          format.json { render json: @event }
        end
      end
    end

    def new
      @event = Event.new

      respond_to do |format|
        format.html # new.html.erb
        format.mobile # new.mobile.erb
        format.json { render json: @event }
      end
    end

  def new2
    @event = Event.new

    respond_to do |format|
      format.html # new.html.erb
      format.mobile # new.mobile.erb
      format.json { render json: @event }
    end
  end

  # GET /weddingevents/1/edit
  def edit
    @event = Event.find(params[:id])

    unless current_user.id == @event.user_id
      redirect_to root_url
    end

    @wallpaper = Wallpaper.new
    @all_wallpapers = Wallpaper.where(:event_id => @event.id)
    @ticket_types = TicketType.where(:event_id => @event.id, :is_deleted => false)
    #@ticket_types = TicketType.where('event_id = ? and (is_deleted = false or is_deleted = ?)', @event.id)
    @cashgifttypes = Cashgifttype.where(:event_id => params[:id], :is_donation=>false)
    @donationtypes = Cashgifttype.where(:event_id => params[:id], :is_donation=>true)
    @attacheds = Attached.find_all_by_event_id(@event.id)
    @allphotos = AlbumPhoto.find_all_by_album_id(params[:id])
    @album = Album.find_by_event_id(@event.id)
    @videos = Video.where(:event_id => @event.id)
    @ticket_type = TicketType.new()
    @sales_person = SalesPerson.new
    @cashgifts = []
    @donations = []

    @registration_list = RegistrationList.where(:event_id =>@event.id).first
    @registration_members = RegistrationMember.where(:registration_list_id =>@registration_list.id)

    @contracts = Contract.find_all_by_event_id(@event.id, :order => 'id')
    @info = []
    allEventTickets = TicketInstance.where("event_id = ? AND (status = 'paid' OR status = 'redeemed')", @event.id)

    @globalTicketCount = 0
    @globalTicketAmount = 0
    @tickets = {}
    @tickets["price"] = {}
    @tickets["quantity"] = {}

    @ticket_types.each do |type|
        @tickets["price"][type.id] = 0
        @tickets["quantity"][type.id] = 0   
        fee = getFee(type.price)

        allEventTickets.each do |ticket|
          if ticket.ticket_type_id == type.id
            @globalTicketAmount = @globalTicketAmount + (ticket.price_paid - (fee * ticket.quantity))

            @globalTicketCount = @globalTicketCount + ticket.quantity
            @tickets["price"][ticket.ticket_type_id] = @tickets["price"][ticket.ticket_type_id] + (ticket.price_paid - (fee * ticket.quantity))
            @tickets["quantity"][ticket.ticket_type_id] = @tickets["quantity"][ticket.ticket_type_id] + ticket.quantity
          end
        end
    end

    ###############################
    ## CAN PROBABLY BE OPTIMIZED ##
    ###############################
    @contracts.each do |contract|
      person = SalesPerson.find(contract.sales_person_id)
      total_sold = 0
      total_amount = 0.00
      sales = []
      @ticket_types.each do |type|

        num = 0
        allEventTickets.each do |ticket|
          if ticket.contract_id == contract.id and ticket.ticket_type_id == type.id
            num = num + ticket.quantity
          end
        end

        fee = getFee(type.price)
        total_sold = total_sold + num

        sales << {:name => type.name, :total => num, :id => type.id, :ticket_price => type.price, :fee => fee}
      end
      @info << {:contract_id => contract.id,
                :sales_person_id => person.id,
                :fname => person.fname,
                :lname => person.lname,
                :email => person.email,
                :total_sold => total_sold,              
                :sales => sales,
                :commission => contract.commission
              }
    end

    if current_user then
        @cashgifttypes.each do |x|
          cgs = CashGift.where(:user_id => current_user.id, :status => "paid", :cashgifttype_id => x.id)
          cgs.each do |y|
            @cashgifts << y
          end
        end
    end
    if current_user then
        @donationtypes.each do |x|
          cgs = CashGift.where(:user_id => current_user.id, :status => "paid", :cashgifttype_id => x.id)
          cgs.each do |y|
            @cashgifts << y
          end
        end
    end

    #@ticket_types = TicketType.find_all_by_event_id(@event.id)

    #@events = Event.all
  end

  def clone
    Resque.enqueue(Jobs::Clone, params[:id])
    respond_to do |format|
      format.json { render json: current_user.events.count}
      format.html { redirect_to '/events', notice: 'Your Event Is Being Cloned.  Please Wait A Few Moments...' }
    end
  end

  def is_cloned
    respond_to do |format|
      format.json { render json: current_user.events.count}    
    end
  end

  def create
    params["event"]["user_id"] = current_user.id

    ## date isn't being used anywhere, shouldn't need this, and might be causing problems anyways
    #if params["event"]["date"].blank?
    #  params["event"]["date"] = nil
    #else
    #  stringer = params["event"]["date"]
    #  d = stringer.split("/").map(&:to_i)
    #  params["event"]["date"] = Date.new(d.third,d.first,d.second)
    #end

    if params[:startTime]
      datetime = params[:startTime].split(" ")
      date = datetime[0].split('-')
      time = datetime[1].split(":")
    
      hour = time[0].to_i
      if datetime[2] == 'pm'
        hour += 12
      end

      params[:event]["startTime"] = DateTime.new(date[0].to_i, date[1].to_i, date[2].to_i, hour, time[1].to_i, 0)
    end

    if params[:startTime]
      datetime = params[:endTime].split(" ")
      date = datetime[0].split('-')
      time = datetime[1].split(":")

      hour = time[0].to_i
      if datetime[2] == 'pm'
        hour += 12
      end
    
      params[:event]["endTime"] = DateTime.new(date[0].to_i, date[1].to_i, date[2].to_i, hour, time[1].to_i, 0)
    end


    @event = Event.new(params[:event])

    if current_user.referred_by
      @event.referrer = current_user.referred_by
      current_user.referred_by = ''
      current_user.save
    end
    @event.url_handle = params["url_handle"]
    #Set defaults
    @event.max_capacity = 0
    @event.allow_comments = true
    @event.auto_approve_photos = false
    @event.show_promotor = true
    @event.show_video_message = false
    @event.show_attendees = false
    @event.include_fees = false
    @event.show_attendees = true
    @event.first_view = true
    @event.has_been_deleted = false
    @event.has_registration = false
    @event.is_private = true
    @event.has_youtube = false

    @event.set_options = false
    @event.set_tickets = false
    @event.set_options = false
    @event.set_donations = false
    @event.set_cg = false
    @event.set_social = false
    @event.set_video = false
    @event.set_photo = false
    @event.set_metric = false

    respond_to do |format|
      if @event.save
        if @event.video and not @event.video == ""
                 # Start transcoding
                 transcode_flv(opentok_flv_url(@event.video), @event.video)
               end
        @album = Album.new(:event_id=>@event.id, :name=>@event.name, :private=>0)
        @album.save
        @registration_list = RegistrationList.new(:event_id=>@event.id)
        @registration_list.save
        @contact_list = ContactList.new(:event_id=>@event.id,:admin=>true, :name=>"List of Ticket Purchasers",:owner_id=>current_user.id)
        @contact_list.save

        (0..20).each do |i|
          if params["custom" + i.to_s]          
            paper = Wallpaper.new(:event_id => @event.id, :wallpaper => params["custom" + i.to_s])          
            paper.save
          end
        end 

        if params[:added_themes]
        params[:added_themes].each_char do |c|
          path = "#{Rails.root}/public/images/theme/theme" + c + ".jpg"
          file = StringIO.new(IO.read(path)) #mimic a real upload file
          file.class.class_eval { attr_accessor :original_filename, :content_type } #add attr's that paperclip needs
          file.original_filename = "theme" + c #assign filename in way that paperclip likes
          file.content_type = "image/jpeg"

          paper = Wallpaper.new(:event_id => @event.id)
          paper.wallpaper = file
          paper.save
        end
        end

        format.html { redirect_to edit_event_path(@event), notice: "Congratulations, Now It's Time To Configure!"}
        format.mobile { redirect_to @event, notice: 'Your Event Was Successfully Created.' }
        format.json { render json: @event, status: :created, location: @event }
      else
       # handle error for url handle in use.
       # if Event.where(:url_handle => @event.url_handle)
       #   flash[:error] = 'That URL Handle Is Already In Use, Please Choose Another!'
       # end
        format.html { render action: "new", alert: @event.errors.full_messages[0] }
        format.mobile { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end


  def update_cg
    @event = Event.find(params[:id])
    if params[:picked].nil?
          @cgts = []
        else
         @cgts = params[:picked]
        end
       Cashgifttype.where(:user_id => current_user.id,:event_id => @event.id ).each do |cg|
         cg.shown = FALSE
         cg.save
       end
       @cgts.each do |cgt|
         c = Cashgifttype.find(cgt.to_s)
         c.shown = TRUE
         c.save
       end

    respond_to do |format|
           format.html { redirect_to @event, notice: 'Your Event Was Successfully Updated.' }
           format.mobile { redirect_to @event, notice: 'Your Event Was Successfully Updated.' }
           format.json { head :no_content }
       end
  end


  def update

    if params["event"]
      if params["event"]["date"].blank?
        params["event"]["date"] = nil
      else
        stringer = params["event"]["date"]
        unless stringer.include? "-"
        d = stringer.split("/").map(&:to_i)
        params["event"]["date"] = Date.new(d.third,d.first,d.second)
        end
      end
    end
    @event = Event.find(params[:id])
    params.delete('id')
    params.delete('action')
    params.delete('controller')

    if params["set_options"]
      @event.set_options = true
    end
    if params["delete_event_image"]
      @event.event_image.destroy
      params.delete('delete_event_image')
    end


#    (0..20).each do |i|
#          if params["custom" + i.to_s]          
#            paper = Wallpaper.new(:event_id => @event.id, :wallpaper => params["custom" + i.to_s])          
#            paper.save
#          end
#        end 

    respond_to do |format|
      if @event.update_attributes(params)
        if params["video"]
        if @event.video and not @event.video == ""
                        # Start transcoding
                        transcode_flv(opentok_flv_url(@event.video), @event.video)
        end
        end
        format.html { redirect_to @event, :notice=> 'Your Event Was Successfully Updated.' }
        format.mobile { redirect_to @event, :notice=> 'Your Event Was Successfully Updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to @event, :alert=> 'There was an issue updating your event, please try again.' }
        format.mobile { redirect_to @event, :alert=> 'There was an issue updating your event, please try again.' }
        format.json { render :json=> @event.errors, :status=> :unprocessable_entity }
      end
    end
  end

  def destroy
    @event = Event.find(params[:id])
    #@event.destroy
    @event.has_been_deleted = TRUE
    @event.save
    respond_to do |format|
      format.html { redirect_to events_url }
      format.mobile { redirect_to events_url }
      format.json { head :no_content }
    end
  end

  def cashout
    id = 0
    if params[:id]
      id = params[:id]
    elsif params[:cashout][:id]
      id = params[:cashout][:id]
    end

    @event = Event.find(id)
    @user = current_user

    unless @event.user_id == @user.id
      redirect_to :back, alert: "You must own the event to cash out"
      return
    end

      # There is a potential race-condition in this function, and after some discussion we decided to just leave it in.
      # We assume that if the first payment succeeds that the second payment also succeeds, and that the database is updated correctly.

      if params[:cashout]
        unless params[:cashout][:cg_key2] == @user.cg_key2
          redirect_to :back, alert: "Security answer is incorrect"
          return
        end
      elsif params[:cg_key2] != @user.cg_key2
        redirect_to :back, alert: "Security answer is incorrect"
        return
      end

      dev = FALSE
      if not dev then
        # Currently, we just send emails.
        Notifier.cashout_request(@user,@user.email,@event).deliver
        Notifier.cashout_request_client(@user,@user.email,@event).deliver
        respond_to do |format|
          format.html { redirect_to events_url, notice: "Your Cash-Out Request Has Been Received And Is Under Review!" }
          format.mobile { redirect_to events_url, notice: "Your Cash-Out Request Has Been Received And Is Under Review!" }
          format.json { head :no_content }
        end
      else
        # The cash-out includes all tickets for the event, that are paid or redeemed, and that have not already been cashed out.
        tickets = TicketInstance.where("host_id = ? AND (status = ? OR status = ?) AND (payout_user_transaction_id IS NULL) AND (price_paid > 0)", @user.id, TicketInstancesController::TICKET_STATUS_PAID, TicketInstancesController::TICKET_STATUS_REDEEMED).reject do |ticket| ticket.event_id != @event.id end

        # Organize the tickets by currency.
        currency_tickets = bucket(tickets) do |ticket|
          ticket.currency_paid
        end

        if currency_tickets.length == 0 then
          error_message = "There are no tickets for this event that have been paid for that have not already been cashed out."
        else
          currency_tickets.each do |currency, local_tickets|
            #@affiliate = @user.referred_by
            local_error = cashout_tickets(local_tickets)
            if local_error and local_error != ""
              if error_message and error_message != ""
                error_message = error_message + "\n" + local_error
              else
                error_message = local_error
              end
            end
          end
        end

        if not error_message then
          respond_to do |format|
            format.html { redirect_to events_url, notice: "Your cash-out has been successfully processed!" }
            format.json { render json: 'success'}
          end
        else
          respond_to do |format|
            format.html { redirect_to events_url, alert: "There was an error processing your cash-out: #{error_message}" }
            format.json { render json: error_message }
          end
        end
      end
  end

  def test_cashout
    @event = Event.find(params[:id])
    @user = current_user

    Notifier.test_cashout(@user,@user.email,@event).deliver
    
    respond_to do |format|
      format.html { redirect_to events_url, notice: "Your Cash-Out Request Has Been Received And Is Under Review!" }
      format.mobile { redirect_to events_url, notice: "Your Cash-Out Request Has Been Received And Is Under Review!" }
      format.json { head :no_content }
    end
  end

  # References a few instance variables that must be defined by the caller.
  # We transfer the total amount, minus fees, to the user, and we transfer the fees to a separate account.
  def cashout_tickets(tickets)
    total_cashout_amount = tickets.map(&:price_paid).reduce(:+)
    total_fees = tickets.map(&:cashout_fee).reduce(:+).round(2)

    # Assumes at least one ticket!
    currency = tickets[0].currency_paid

    #affiliate_payout = [total_cashout_amount * 0.025, max_affiliate_payout_for(@affiliate, @user)].min.round(2)

    # The affiliate payout comes out of the fees, rather than the gross.
    #fees = (total_fees - affiliate_payout).round(2)
    fees = (total_fees).round(2)


    #user_payout = total_cashout_amount - (fees + affiliate_payout)
    user_payout = total_cashout_amount - (fees)

    event_name = @event.name
    
    transfer_subject = "Cash-out for #{event_name}"
    transfer_note = "Cash-out Amount: #{total_cashout_amount} #{currency}"
    if user_payout > 0 then
      transfer_note = transfer_note + ", Paid Amount: #{user_payout} #{currency}"
    end
    if total_fees > 0 then
      # The user note has affiliate and fees grouped together.
      user_transfer_note = transfer_note + ", Fees: #{total_fees} #{currency}"
    end
    if fees > 0 then
      transfer_note = transfer_note + ", Fees: #{fees} #{currency}"
    end
    #if affiliate_payout > 0 then
    #  transfer_note = transfer_note + ", Affiliate Payout: #{affiliate_payout} #{currency}"
    #end

    # Pay Fees (to ourselves)
    pay_result = paypal_pay(FEES_PAYPAL_ACCOUNT, fees, currency, transfer_subject, transfer_note)
    fee_response = pay_result[:response]
    fee_transaction = pay_result[:transaction]
    if not fee_response.success? then
      return fee_response.message
    end

    # This loops over the collection, saving each element, so it is not ideal.
    # A bulk update would use less database resources, but this method has easier maintenance.
    tickets.each do |ticket|
      ticket.payout_fee_transaction_id = fee_transaction.id
      ticket.save!
    end
    
    # Pay User
    pay_result = paypal_pay(@user.email, user_payout, currency, transfer_subject, user_transfer_note)
    user_response = pay_result[:response]
    user_transaction = pay_result[:transaction]
    
    if not user_response.success? then
      return user_response.message
    end

    # This loops over the collection, saving each element, so it is not ideal.
    # A bulk update would use less database resources, but this method has easier maintenance.
    tickets.each do |ticket|
      ticket.payout_user_transaction_id = user_transaction.id
      ticket.save!
    end
    
    # Pay Affiliate
#    if affiliate_payout > 0 then
#      pay_result = paypal_pay(@affiliate.email, affiliate_payout, currency, transfer_subject, transfer_note)
#      affiliate_response = pay_result[:response]
#      affiliate_transaction = pay_result[:transaction]
#
#      if not affiliate_response.success? then
#        return affiliate_response.message
#      end
#
#      # This loops over the collection, saving each element, so it is not ideal.
#      # A bulk update would use less database resources, but this method has easier maintenance.
#      tickets.each do |ticket|
#        ticket.payout_affiliate_transaction_id = affiliate_transaction.id
#        ticket.save!
#      end
#    end
#
   Notifier.cashout_request_processed(@user,@user.email,@event,transfer_note ).deliver
   return nil
  end


  def cashout_admin
      @event = Event.find(params[:id])
      @user = current_user

      # There is a potential race-condition in this function, and after some discussion we decided to just leave it in.
      # We assume that if the first payment succeeds that the second payment also succeeds, and that the database is updated correctly.

      dev = TRUE
      if not dev then
        # Currently, we just send emails.
        Notifier.cashout_request(@user,@user.email,@event).deliver
        Notifier.cashout_request_client(@user,@user.email,@event).deliver
        respond_to do |format|
          format.html { redirect_to events_url, notice: "Your Cash-Out Request Has Been Received And Is Under Review!" }
          format.json { head :no_content }
        end
      else
        # The cash-out includes all tickets for the event, that are paid or redeemed, and that have not already been cashed out.
        tickets = TicketInstance.where("host_id = ? AND (status = ? OR status = ?) AND (payout_user_transaction_id IS NULL) AND (price_paid > 0)", @user.id, TicketInstancesController::TICKET_STATUS_PAID, TicketInstancesController::TICKET_STATUS_REDEEMED).reject do |ticket| ticket.event_id != @event.id end

        # Organize the tickets by currency.
        currency_tickets = bucket(tickets) do |ticket|
          ticket.currency_paid
        end

        if currency_tickets.length == 0 then
          error_message = "There are no tickets for this event that have been paid for that have not already been cashed out."
        else
          currency_tickets.each do |currency, local_tickets|
            #@affiliate = @user.referred_by
            local_error = cashout_tickets(local_tickets)
            if local_error and local_error != ""
              if error_message and error_message != ""
                error_message = error_message + "\n" + local_error
              else
                error_message = local_error
              end
            end
          end
        end

        if not error_message then
          respond_to do |format|
            format.html { redirect_to events_url, notice: "Your cash-out has been successfully processed!" }
            format.json { head :no_content }
          end
        else
          respond_to do |format|
            format.html { redirect_to events_url, alert: "There was an error processing your cash-out: #{error_message}" }
            format.json { head :no_content }
          end
        end
      end
  end

  def search
    name = params['name']
    category = params['category']
    afterDate = params['after']
    beforeDate = params['before']
    distance = params['distance'].to_i
    location = Geocoder.search(request.ip)
    puts(request.ip)

    if afterDate == '' && beforeDate == ''
     if category == "All"
       @events_results = Event.find(:all, :conditions => ['lower(name) LIKE LOWER(?) and is_private = FALSE and has_been_deleted = FALSE', "%#{name.gsub(/[^a-zA-Z ]/,'').gsub(/ +/,' ')}%"])
     else
       @events_results = Event.find(:all, :conditions => ['lower(name) LIKE LOWER(?) and category LIKE ? and is_private = FALSE and has_been_deleted = FALSE', "%#{name.gsub(/[^a-zA-Z ]/,'').gsub(/ +/,' ')}%", category])
     end

   elsif afterDate != '' && beforeDate == ''
     formatAfterDate = afterDate[6..9] + "-" + afterDate[0..1] + "-" + afterDate[3..4] + " 00:00:01"
     parseAfterDate = DateTime.parse(formatAfterDate)
     puts(parseAfterDate)

     if category == "All"
       @events_results = Event.where("lower(name) LIKE LOWER(?) AND \"startTime\" >= ? AND is_private = false AND has_been_deleted = false", "%#{name.gsub(/[^a-zA-Z ]/,'').gsub(/ +/,' ')}%", parseAfterDate)
     else
       @events_results = Event.where("lower(name) LIKE LOWER(?) AND \"startTime\" >= ? AND category = ? AND is_private = false AND has_been_deleted = false", "%#{name.gsub(/[^a-zA-Z ]/,'').gsub(/ +/,' ')}%", parseAfterDate, category)
     end

   elsif afterDate == '' && beforeDate != ''
     formatBeforeDate = beforeDate[6..9] + "-" + beforeDate[0..1] + "-" + beforeDate[3..4] + " 23:59:59"
     parseBeforeDate = Date.parse(formatBeforeDate)

     if category == "All"
       @events_results = Event.where("lower(name) LIKE LOWER(?) AND \"endTime\" <= ? AND is_private = false AND has_been_deleted = false", "%#{name.gsub(/[^a-zA-Z ]/,'').gsub(/ +/,' ')}%", parseBeforeDate)
     else
       @events_results = Event.where("lower(name) LIKE LOWER(?) AND \"endTime\" <= ? AND category = ? AND is_private = false AND has_been_deleted = false", "%#{name.gsub(/[^a-zA-Z ]/,'').gsub(/ +/,' ')}%", parseBeforeDate, category)
     end

   else
     formatAfterDate = afterDate[6..9] + "-" + afterDate[0..1] + "-" + afterDate[3..4] + " 00:00:01"
     formatBeforeDate = beforeDate[6..9] + "-" + beforeDate[0..1] + "-" + beforeDate[3..4] + " 23:59:59"
     parseAfterDate = Date.parse(formatAfterDate)
     parseBeforeDate = Date.parse(formatBeforeDate)

     if category == "All"
       @events_results = Event.where("lower(name) LIKE LOWER(?) AND \"startTime\" >= ? AND \"startTime\" <= ? AND is_private = false AND has_been_deleted = false", "%#{name.gsub(/[^a-zA-Z ]/,'').gsub(/ +/,' ')}%", parseAfterDate, parseBeforeDate)
     else
       @events_results = Event.where("lower(name) LIKE LOWER(?) AND \"startTime\" >= ? AND \"startTime\" <= ? AND category = ? AND is_private = false AND has_been_deleted = false", "%#{name.gsub(/[^a-zA-Z ]/,'').gsub(/ +/,' ')}%", parseAfterDate, parseBeforeDate, category)
     end
   end


    @events = Event.where(:is_private => false, :has_been_deleted => false)

    if distance > 0
      approved_events = []
      @events_results.each do|e|
        lat1 = location[0].latitude
        lon1 = location[0].longitude
        distancekm = (Geocoder::Calculations.distance_between([lat1,lon1], [e.lat,e.lon]))/0.62137
        puts (distancekm)

        if distancekm < distance
          approved_events << e
        end
      end

      @events_results = approved_events
    end
    respond_to do |format|
      format.html # search.html.erb
      format.mobile
      format.json { render json: to_json_search(@users) }
    end
  end

  def search_by_date
    date = params['date']['from']
    to = params['date']['to']

    formatted = date[6..9] + "-" + date[0..1] + "-" + date[3..4] + " 00:00:01" #less than ideal, should pass to
                                                                 #controller as formatted date  
    formatted2 = to[6..9] + "-" + to[0..1] + "-" + to[3..4] + " 23:59:59"                                                                 
    #@events = Event.find(:all, :conditions => ["endTime < ?", formatted])
    @events_results= []
    @events = Event.where(:is_private => false,:has_been_deleted => false)
    allEvents = Event.where(:is_private => false,:has_been_deleted => false)

    allEvents.each do |e|
      if ((Time.parse(e.startTime.to_s).to_i > Time.parse(formatted.to_s).to_i) and (Time.parse(e.startTime.to_s).to_i < Time.parse(formatted2.to_s).to_i))
        @events_results << e
      end
    end
    respond_to do |format|
      format.html # search.html.erb
      format.json { render json: to_json_search(@users) }
    end
  end
  def search_by_city
    city = params['city']
    @events = Event.find(:all, :conditions => [ "lower(city) = ?", city.downcase ])
    respond_to do |format|
      format.html # search.html.erb
      format.json { render json: to_json_search(@users) }
    end
  end

  def mobile_search
    @events = Event.all
  end

  def add_to_cal

    @event = Event.find(params[:e_id])

    respond_to do |format|
      format.html
      format.ics 
      format.vcs 
      format.mobile
    end
  end

  def widget_tickets
    @event = Event.find(params[:e_id])
    @tickettypes = TicketType.where(:event_id => @event.id)
    @tickets = @tickettypes
    @ticket_instance = TicketInstance.new

    if current_user then
      @ticket_instance.guest_id = current_user.id
    end

    @ticket_instance.guest_email = current_user ? current_user.email : ""
    @ticket_instance.guest_name = current_user ? current_user.display_name : ""
    @ticket_instance.status = TICKET_STATUS_UNPAID
    @ticket_instance.host_id = @event.user_id
    @quantities = @event.ticket_types.each do |ticket_type|
      if ticket_type.is_deleted or ticket_type.is_deleted == nil
        { ticket_type: ticket_type, quantity: 0 }
      end
    end  
  end

  def widget_users
    @user = User.find(params[:id])
    @events = Event.where(:referrer => params[:id], :has_been_deleted => false)
  end

  def find
    @events = Event.where(:is_private => false, :has_been_deleted => false)
  end

  def checkURL
     data = true
     @url = Event.where(:url_handle => params[:urlHandle])

     unless (@url.blank? or @url.nil?)
       data = false
     end

     render json: data
  end

  def getFee(price)
    process_fee = 0

    if price == 0
      process_fee = 0
    elsif price < 5
      process_fee = 0.25
    elsif price < 10
      process_fee = 0.5
    elsif price < 20
      process_fee = 0.75
    else
      process_fee = 0.99
    end

    return (price * 0.025) + process_fee
  end
end
