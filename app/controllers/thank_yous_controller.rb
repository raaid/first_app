class ThankYousController < ApplicationController

  before_filter :require_user, :only => [:new, :create, :send_thanks_by_id, :destroy, :index, :edit, :update]
  layout 'thank_you_layout', only: [:show]
  before_filter :mobilize
  respond_to :html, :js, :mobile, :json

  def index
    @thank_you = ThankYou.new
    @thanks = []
    temp_thank_id = 0

    tickets = TicketInstance.where(:event_id => params[:id])
    tickets.each do |g|
        @thanks << thanks_from_ticket(g, temp_thank_id)
        temp_thank_id = temp_thank_id + 1
    end

    free_typed_tickets = ThankYou.where(ticket_instance_id: nil, sender_id: current_user.id)
    free_typed_tickets.each do |ft|
      @thanks << thanks_from_existing_thanks(ft, temp_thank_id)
      temp_thank_id = temp_thank_id + 1
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @thank_yous }
    end
  end

  def thanks_from_ticket(ticket, client_id)
    thank_you = ThankYou.where(:ticket_instance_id => ticket.id).first
    { id: (thank_you and thank_you.id),
      client_id: client_id,
      gift_id: ticket.id,
      gift_name: ticket.ticket_type.name,
      gift_price: ticket.price_paid,
      to_name: (ticket and ticket.guest_name),
      to_email: (ticket and ticket.guest_email),
      opentok_video_id: (thank_you != nil and thank_you.opentok_video_id),
      thanked: (thank_you != nil),
      sent: (thank_you != nil and thank_you.sent?)
    }
  end


  def thanks_from_existing_thanks(thank_you, client_id)
    if thank_you.ticket_instance_id
      thanks_from_ticket(thank_you.gift, client_id)
    else
      { id: thank_you.id,
        client_id: client_id,
        gift_name: "No Ticket Specified",
        gift_price: "No Price Specified",
        to_name: thank_you.to_name,
        to_email: thank_you.to_email,
        to_note: thank_you.to_note,
        opentok_video_id: thank_you.opentok_video_id,
        thanked: true,
        sent: thank_you.sent?
      }
    end
  end

  # GET /thank_yous/1
  # GET /thank_yous/1.json
  def show
    @thank_you = ThankYou.find(params[:id])
    @local_html = opentok_video_html(@thank_you.opentok_video_id)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @thank_you }
    end
  end

  # GET /thank_yous/new
  # GET /thank_yous/new.json
  def new
    @thank_you = ThankYou.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: thanks_from_existing_thanks(@thank_you, 0) }
    end
  end

  # GET /thank_yous/1/edit
  def edit
    @thank_you = ThankYou.find(params[:id])
  end

  # POST /thank_yous
  # POST /thank_yous.json
  def create
    thank_you_params = params.reject do |key, value|
      not (["ticket_instance_id", "to_email", "to_name", "to_note", "sent_date", "opentok_video_id"].include?(key) and value != "null")
    end

    thank_you_params[:sender_id] = current_user.id

    @thank_you = ThankYou.new(thank_you_params)

    respond_to do |format|
      if @thank_you.save
        # Start transcoding
        transcode_flv(opentok_flv_url(@thank_you.opentok_video_id), @thank_you.opentok_video_id)

        format.html { redirect_to @thank_you, notice: 'Your Video Thank You Was Successfully Created.' }
        format.json { render json: @thank_you, status: :created, location: @thank_you }
      else
        format.html { render action: "new" }
        format.json { render json: @thank_you.errors, status: :unprocessable_entity }
      end
    end
  end

  # Plain "send" is already used by the controller.
  def send_thanks_by_id
    thanks = ThankYou.find(params[:id])
    send_thanks(thanks)

    render json: nil
  end

  def send_thanks(thanks)
    # TODO Actually send the email.
    Resque.enqueue(Jobs::Deliver_thank_you_email, thanks.id)
    #Notifier.deliver_thank_you_email(thanks)

    thanks.sent_date = Time.now
    thanks.save!
  end

  # PUT /thank_yous/1
  # PUT /thank_yous/1.json
  def update
    @thank_you = ThankYou.find(params[:id])

    respond_to do |format|
      if @thank_you.update_attributes(params[:thank_you])
        format.html { redirect_to @thank_you, notice: 'Your Video Thank You Was Successfully Updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @thank_you.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /thank_yous/1
  # DELETE /thank_yous/1.json
  def destroy
    @thank_you = ThankYou.find(params[:id])
    @thank_you.destroy

    respond_to do |format|
      format.html { redirect_to thank_yous_url }
      format.json { head :no_content }
    end
  end
end
