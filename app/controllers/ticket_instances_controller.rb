require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'
require 'base64'
require 'rubygems'
require 'active_merchant'

class TicketInstancesController < ApplicationController

  before_filter :require_user, :only => [:index]
  before_filter :mobilize
  respond_to :html, :js, :mobile, :json

  TICKET_STATUS_UNPAID = "unpaid"
  TICKET_STATUS_PAID = "paid"
  TICKET_STATUS_REFUNDED = "refunded"
  TICKET_STATUS_REDEEMED = "redeemed"

  def index
    # This could be made faster, by e.g. ordering the elements by ticket_type_id as part of the query.
    @ticket_instances = get_relevant_instances(params)
    @ticket_type = []
    @ticket_instances.each do |ticket|
      tt = TicketType.find_by_id(ticket.ticket_type_id)
      unless @ticket_type.include?(tt)
        @ticket_type << tt
      end
    end

    if not admin and @ticket_instances.length == 0 then
      respond_to do |format|
        format.html #{ redirect_to redirect_non_admins_to }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @ticket_instances }
      end
    end
  end

  def get_relevant_instances(params)
    if params[:ticket_type_id] then
      TicketInstance.find_all_by_ticket_type_id(params[:ticket_type_id])
    elsif params[:event_id] then
      TicketInstance.find_all_by_event_id(params[:event_id])
    elsif admin then
      TicketInstance.all
    else
      TicketInstance.find_all_by_host_id(current_user.id)
    end
  end

  # GET /ticket_instances/1
  # GET /ticket_instances/1.json
  def show
    @ticket_instance = TicketInstance.find(params[:id])

    tickets = TicketInstance.where(:guest_email => @ticket_instance.guest_email, :ticket_type_id => @ticket_instance.ticket_type_id)

    @base_ticket = tickets[0]
    @tickets = tickets
    type = TicketType.find(@ticket_instance.ticket_type_id)
    @event = Event.find(type.event_id)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @ticket_instance }
    end
  end

  def resend
    @ticket_instance = TicketInstance.find(params[:id])
    Resque.enqueue(Jobs::Resend, @ticket_instance.id)

    respond_to do |format|
      format.html { redirect_to manage_ticket_type_path(@ticket_instance.event_id), notice: 'Ticket has been sent to ' + @ticket_instance.guest_name }
      format.json { render json: @ticket_instance }
    end
  end

  def resend_by_email
    @ticket_instance = TicketInstance.find_by_guest_email(params[:email][:email])
    if @ticket_instance
      Resque.enqueue(Jobs::Resend_by_email, @ticket_instance.id)   

      respond_to do |format|
        format.html { redirect_to root_path, notice: 'Ticket has been sent to ' + @ticket_instance.guest_name }
        format.mobile { redirect_to event_path(@ticket_instance.event_id), notice: 'Ticket has been sent to ' + @ticket_instance.guest_name }
        format.json { render json: @ticket_instance }
      end
    else
      respond_to do |format|
        format.html { redirect_to event_path(params[:email][:event]), alert: params[:email][:email] + " is not associated with this event"}
        format.mobile { redirect_to event_path(params[:email][:event]), alert: params[:email][:email] + " is not associated with this event"}
        format.json { render json: @ticket_instance }
      end
    end
  end

  # GET /ticket_instances/new
  # GET /ticket_instances/new.json
  def new
    event = Event.find(params[:event_id])
    @event = event
    @user = User.find(@event.user_id)
    @ticket_instance = TicketInstance.new
    @capacity = 0
    @christmas_party = 0

    if event.id == 25
      @christmas_party = 1
      total = 0
      TicketInstance.where(:ticket_type_id => 24,:status => "paid").each do |t1|
      total += t1.quantity
      end
      t2 = TicketInstance.where(:ticket_type_id => 24,:status => "redeemed").each do |t2|
        total += t2.quantity
      end
      TicketInstance.where(:ticket_type_id => 25,:status => "paid").each do |t3|
        total += t3.quantity
      end
      TicketInstance.where(:ticket_type_id => 25,:status => "redeemed").each do |t4|
      total += t4.quantity
      end

      @capacity = total
    end
    if current_user then
      @ticket_instance.guest_id = current_user.id
    end
    @ticket_instance.guest_email = current_user ? current_user.email : ""
    @ticket_instance.guest_name = current_user ? current_user.display_name : ""
    @ticket_instance.status = TICKET_STATUS_UNPAID
    @ticket_instance.host_id = event.user_id

    @quantities = event.ticket_types.each do |ticket_type|
      { ticket_type: ticket_type, quantity: 0 }
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ticket_instance }
    end
  end

  # GET /ticket_instances/1/edit
  def edit
    @ticket_instance = TicketInstance.find(params[:id])
  end

  # POST /ticket_instances
  # POST /ticket_instances.json
  def create
    successes = []
    failures = []

    quantities = params[:ticket_instance][:quantities]
    contract_id = params[:ticket_instance][:contract_id]

    if quantities == nil
      return bounce("Please select a ticket to buy");
    end
    params[:ticket_instance].delete(:quantities)
    total_price = 0

    first_currency = nil

    include_fees = true

    for array_entry in quantities
      # The entries are pair-wise, the real data is in the second element.
      line_item = array_entry[1]
      local_ticket_type = TicketType.find(line_item[:ticket_type])

      event = Event.where(:id => local_ticket_type.event_id ).first
      unless event.include_fees == true
        include_fees = false
      end

      # The currencies have to all be the same.
      if line_item[:quantity].to_i > 0
        puts "FC:#{first_currency} #{local_ticket_type.currency}"
        first_currency = local_ticket_type.currency unless first_currency
        if first_currency != local_ticket_type.currency then
          return bounce('PayPal can only process one currency at a time. Tickets priced in different currencies must be purchased separately!')
        end
      end

      if local_ticket_type.groupable then
        qloop_repeat = 1
        qloop_quantity = line_item[:quantity].to_i
      else
        qloop_repeat = line_item[:quantity].to_i
        qloop_quantity = 1
      end

      unless qloop_quantity == 0
        for qloop_iter in Range.new(1, qloop_repeat)
          @ticket_instance = new_unpaid_ticket(local_ticket_type, qloop_quantity, params[:ticket_instance])
          @ticket_instance.contract_id = contract_id
          if @ticket_instance.save
            successes << @ticket_instance
            total_price = total_price + @ticket_instance.price_paid
          else
            failures << @ticket_instance
          end
        end
      end
    end

    if total_price == 0
      #Resque.enqueue(Jobs::Deliver_ticket_purchase_email, successes)
      Notifier.deliver_ticket_purchase_email(successes)
    end

    # The fee is 2.9% of the total, plus 30 cents.
    if include_fees and total_price > 0
    paypal_processing_fee = (total_price * 0.029) + 0.3
    total_price += paypal_processing_fee
    end

    if failures.length <= 0 and total_price == 0 and successes.length > 0 then
  #    params[:id] = paypal_transaction_id
  #    tickets_paid

      redirect_to :back, notice: 'Your tickets were successfully purchased'
      return
    elsif failures.length <= 0 and successes.length > 0 then
      # In the database, the ticket price is a BigNum, but we have to send a fixnum to PayPal.
      # PayPal wants an integer quantity of the smallest denomination. Here we're assuming that is cents.
      items = successes.map do |ticket_instance|
        { name: ticket_instance.ticket_type.name, description: "Tickets for #{ticket_instance.event_name}",
          quantity: ticket_instance.quantity, amount: (ticket_instance.ticket_type.price * 100).to_i, currency: ticket_instance.ticket_type.currency }
      end

      if include_fees
      items = add_paypal_processing_fee(items)
      end

      cancel_url = root_url
      callback_url = url_for :controller => 'ticket_instances', :action => 'tickets_paid', :paid_ticket_ids => (successes.map do |ticket| ticket.id end).join('-'), items: items


      if total_price > 0
        redirect_to_paypal_express(items, callback_url, cancel_url)
      end
    else
      respond_to do |format|
        format.html { redirect_to :back, alert: 'There Was An Issue Creating Your Tickets, Please Try Again.' }
        format.json { render json: failures[0].errors, status: :unprocessable_entity }
      end
    end
  end

  def new_unpaid_ticket(local_ticket_type, quantity, extra_params)
    result = TicketInstance.new(extra_params)
    result.ticket_type_id = local_ticket_type.id
    
    result.quantity = quantity
    result.event_id = local_ticket_type.event_id
    result.price_paid = quantity * local_ticket_type.price

    if result.price_paid > 0
      result.status = TICKET_STATUS_UNPAID
    else
      result.status = TICKET_STATUS_PAID
    end

    result.currency_paid = local_ticket_type.currency

    return result
  end

  def tickets_paid
    Resque.enqueue(Jobs::Tickets_paid, params[:token], params[:paid_ticket_ids], request.remote_ip)
    paid_ticket_ids = params[:paid_ticket_ids].split('-')

    if paid_ticket_ids.length > 0
      paid_ticket = TicketInstance.find(paid_ticket_ids[0])
      @contact_list = ContactList.where(:admin => true, :event_id => paid_ticket.event_id).first
      respond_to do |format|
        format.html { redirect_to Event.find(@contact_list.event_id), notice: 'Your tickets were successfully purchased!' }
      end
    end
  end

  # PUT /ticket_instances/1
  # PUT /ticket_instances/1.json
  def update
    @ticket_instance = TicketInstance.find(params[:id])

    respond_to do |format|
      if @ticket_instance.update_attributes(params[:ticket_instance])
        format.html { redirect_to @ticket_instance, notice: 'Your Ticket instance was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @ticket_instance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ticket_instances/1
  # DELETE /ticket_instances/1.json
  def destroy
    if not admin then
      respond_to do |format|
        format.html { redirect_to redirect_non_admins_to }
        format.json { head :no_content }
      end
    else
      @ticket_instance = TicketInstance.find(params[:id])
      @ticket_instance.destroy

      respond_to do |format|
        format.html { redirect_to ticket_instances_url }
        format.json { head :no_content }
      end
    end
  end

  def barcode
    render text: TicketInstancesController.generate_barcode(params[:id])
  end

  def self.generate_barcode(id)
    image = Base64.encode64((Barby::Code128B.new(id).to_image).resize(200, 200).to_string)

    result = "<img src=\"data:image/png;base64,#{image}\" />"
    result
  end

  def redeem
    if params[:ticket] and params[:ticket][:id] then
      ticket_id = params[:ticket][:id]
    else
      ticket_id = params[:id]
    end


    @ticket_instance = TicketInstance.find(ticket_id)
    response = "error4"
    details = ""
    if @ticket_instance.status == TICKET_STATUS_REDEEMED
      response = "error1"
      details = "Details\nTicket ID:#{ticket_id}\nQuantity:#{@ticket_instance.quantity}\nType:#{TicketType.find_by_id(@ticket_instance.ticket_type_id).name}"
    elsif @ticket_instance.status == TICKET_STATUS_UNPAID
      response = "error2"
      details = "Details\nTicket ID:#{ticket_id}\nQuantity:#{@ticket_instance.quantity}\nType:#{TicketType.find_by_id(@ticket_instance.ticket_type_id).name}"
    elsif @ticket_instance.status == TICKET_STATUS_REFUNDED
      response = "error3"
      details = "Details\nTicket ID:#{ticket_id}\nQuantity:#{@ticket_instance.quantity}\nType:#{TicketType.find_by_id(@ticket_instance.ticket_type_id).name}"
    elsif @ticket_instance.status == TICKET_STATUS_PAID
      @ticket_instance.update_attributes(status: TICKET_STATUS_REDEEMED)
      response = "ok"
      details = "Details\nTicket ID:#{ticket_id}\nQuantity:#{@ticket_instance.quantity}\nType:#{TicketType.find_by_id(@ticket_instance.ticket_type_id).name}"
    end

    

    respond_to do |format|
      format.html { redirect_to action: :index, notice: 'Your Ticket Was Successfully Redeemed!', event_id: params[:event_id] }
      format.json { render json: {response:response,details:details}  }
    end
  end

  def search_by_email
    params[:email].downcase!

    @tickets = TicketInstance.find_all_by_guest_email(params[:email])

    respond_to do |format|
      format.html { redirect_to action: :index, notice: 'Your Ticket Was Successfully Redeemed!', event_id: params[:event_id] }
      format.json { render json: to_json_email(@tickets)  }
    end
  end

  def to_json_email(emails)

    if emails.length > 0

      results = []
      results << {name: emails[0].guest_name}
      emails.each do |ticket|
        results << { id: ticket.id,
                   status: ticket.status,details:"Details: #{ticket.quantity} X #{TicketType.find_by_id(ticket.ticket_type_id).name}"}
      end
    
      return results
    else
      return
    end
  end

  def tickets_successfully_purchased

  end

  def tickets_error

  end

end
