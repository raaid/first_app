class SalesPeopleController < ApplicationController
  # GET /sales_people
  # GET /sales_people.json
  def index

    @contracts = Contract.find_all_by_event_id(params[:event_id], :order => 'id')
    @ticket_types = TicketType.find_all_by_event_id(params[:event_id])
    @info = []
    allEventTickets = TicketInstance.where("event_id = ? AND (status = 'paid' OR status = 'redeemed')", params[:event_id])

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

    @sales_person = SalesPerson.new
    @event = Event.find(params[:event_id])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sales_people }
    end
  end

  # GET /sales_people/1
  # GET /sales_people/1.json
  def show
    @sales_person = auth(params[:pass], params[:id])

    unless @sales_person
      return
    end

    @pass = params[:pass]

    allcontracts = Contract.find_all_by_sales_person_id(params[:id])
    @contracts = []

    allcontracts.each do |contract|
      event = Event.find(contract.event_id)
      owner = User.find(event.user_id)

      ticket_types = TicketType.find_all_by_event_id(contract.event_id)
      tickets = []

      ticket_types.each do |type|
        allTickets = TicketInstance.where("contract_id = ? AND ticket_type_id = ? AND (status = 'paid' OR status = 'redeemed')", contract.id, type.id)

        amount = 0
        quantity = 0
        fee = getFee(type.price)
        allTickets.each do |ticket|
          quantity = quantity + ticket.quantity
          amount = amount + ((ticket.price_paid - (fee * ticket.quantity)) * (contract.commission / 100))
        end

        tickets << {
                    :name => type.name,
                    :quantity => quantity,
                    :amount => amount,
                    :ticket_price => type.price
                  }
      end

      @contracts << {
                      :id => contract.id,
                      :event_name => event.name,
                      :event_date => event.startTime.strftime("%Y-%m-%d"),
                      :owner => owner.display_name,
                      :tickets => tickets,
                      :commission => contract.commission,
                      :link => root_url + 'events/' + event.id.to_s + "?refer=" + contract.id.to_s
                    }
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sales_person }
    end
  end

  # GET /sales_people/new
  # GET /sales_people/new.json
  def new
    @sales_person = SalesPerson.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sales_person }
    end
  end

  # GET /sales_people/1/edit
  def edit
    @sales_person = auth(params[:pass], params[:id])

    unless @sales_person
      return
    end

    @pass = params[:pass]
   # @sales_person = SalesPerson.find(params[:id])
  end

  # POST /sales_people
  # POST /sales_people.json
  def create
    @sales_person = SalesPerson.find_by_email(params[:email])

    unless @sales_person
      @sales_person = SalesPerson.new(fname: params[:fname], lname: params[:lname], email: params[:email])      
      @sales_person.save
    end    

    @contract = Contract.new(:event_id => params[:event_id], :sales_person_id => @sales_person.id, :commission => params[:commission])
    @contract.save

    @ticket_types = TicketType.where(:event_id => params[:event_id], :is_deleted => false)
    sales = []
    @ticket_types.each do |type|
      sales << {:name => type.name, :id => type.id, :ticket_price => type.price}
    end
    @info = {:contract_id => @contract.id,
              :sales_person_id => @sales_person.id,
              :fname => @sales_person.fname,
              :lname => @sales_person.lname,
              :email => @sales_person.email,
              :sales => sales,
              :commission => @contract.commission
            }
    
    respond_to do |format|
      if @contract.save
        
        Resque.enqueue(Jobs::Sales_person_invite, @sales_person.id, params[:event_id]) if @sales_person.valid?
        #Notifier.sales_person_invite(@sales_person, owner_name, link).deliver if @sales_person.valid?

        format.html { redirect_to sales_index_path(:event_id => params[:event_id]), notice: 'Sales person was successfully created.' }
        format.json { render json: @info, status: :created, location: @sales_person }
      else
        format.html { redirect_to sales_index_path(:event_id => params[:event_id]), alert: 'Sales person could not be created' }
        format.json { render json: @sales_person.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sales_people/1
  # PUT /sales_people/1.json
  def update
    #@sales_person = SalesPerson.find(params[:id])
    @sales_person = auth(params[:pass], params[:id])

    unless @sales_person
      return
    end

    old_email = @sales_person.email

    respond_to do |format|
      if @sales_person.update_attributes(params[:sales_person])
        secret = Digest::SHA1.hexdigest("Kzgg4cb9hThp7zSwL3Ta")
        a = ActiveSupport::MessageEncryptor.new(secret)
        pass = a.encrypt_and_sign(@sales_person.email)

        new_email = @sales_person.email
        notice = 'Profile was successfully updated'

        unless old_email == new_email
          link = root_url + "sales_people/" + @sales_person.id.to_s + "?pass=" + CGI::escape(pass)
          Notifier.sales_person_update(@sales_person, link).deliver
          notice = "An email has been sent to your new address with a new login link"
        end

        format.html { redirect_to :controller => 'sales_people', :action => 'show', :id => @sales_person.id, :pass => pass, notice: notice}
        #format.html { redirect_to @sales_person(:pass => pass), notice: 'Sales person was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @sales_person.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sales_people/1
  # DELETE /sales_people/1.json
  def destroy
    @sales_person = SalesPerson.find(params[:id])
    @sales_person.destroy

    respond_to do |format|
      format.html { redirect_to sales_people_url }
      format.json { head :no_content }
    end
  end

  def auth(pass, id)
    begin
      secret = Digest::SHA1.hexdigest("Kzgg4cb9hThp7zSwL3Ta")
      c = ActiveSupport::MessageEncryptor.new(secret)
      email = c.decrypt_and_verify(pass)
      @sales_person = SalesPerson.find_by_email(email)
    rescue
      redirect_to root_url
      return
    end

    if @sales_person
      unless @sales_person.id.to_s == id
        redirect_to root_url
        return
      end
    else 
      redirect_to root_url
      return
    end

    return @sales_person
  end

  def resend
    secret = Digest::SHA1.hexdigest("Kzgg4cb9hThp7zSwL3Ta")
    a = ActiveSupport::MessageEncryptor.new(secret)
    pass = a.encrypt_and_sign(params[:email])

    @sales_person = SalesPerson.find_by_email(params[:email])

    unless @sales_person
      redirect_to root_url, alert: "A sales person with that email address does not exist"
    else        
      link = root_url + "sales_people/" + @sales_person.id.to_s + "?pass=" + CGI::escape(pass)
      Notifier.sales_person_resend(@sales_person, link).deliver
      redirect_to root_url, notice: "email has been sent to " + params[:email]
    end
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
