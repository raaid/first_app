class TicketTypesController < ApplicationController

  before_filter :require_user
  before_filter :mobilize
  respond_to :html, :js, :mobile, :json

  def index
    # If an event ID is specified, then list ticket types for that event.
    # If we are an admin, then we can see all ticket types.
    # If neither is the case, this controller should not be called and the only guarantee is that it won't do anything bad.
    @ticket_types = []
    if params[:event_id] != nil then
      @event = Event.find(params[:event_id])
      @ticket_types = TicketType.find_all_by_event_id(params[:event_id])
      event = Event.find(params[:event_id])
      @user = User.find(event.user_id)
    elsif admin then
      @event = nil
      @ticket_types = TicketType.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.mobile # index.html.erb
      format.json { render json: @ticket_types }
    end
  end

  # GET /ticket_types/1
  # GET /ticket_types/1.json
  def show
    @ticket_type = TicketType.find(params[:id])
    @tickets = TicketInstance.find(:all, :conditions => ['ticket_type_id = ? and (status = ? or status = ?)', @ticket_type.id, "paid", "redeemed"])
    
    respond_to do |format|
      format.html # show.html.erb
      format.mobile # show.html.erb
      format.json { render json: @ticket_type }
    end
  end

  # GET /ticket_types/new
  # GET /ticket_types/new.json
  def new
    @event = Event.find(params[:event_id])
    @ticket_type = TicketType.new
    @ticket_type.event_id = @event.id
    @ticket_type.sell_from = Time.now
    @ticket_type.sell_to = @event.date
    @ticket_type.event_name = @event.name
    @ticket_type.groupable = FALSE
    @ticket_type.currency = 'CAD'

    respond_to do |format|
      format.html # new.html.erb
      format.mobile # new.html.erb
      format.json { render json: @ticket_type }
    end
  end

  # GET /ticket_types/1/edit
  def edit
    @ticket_type = TicketType.find(params[:id])
  end

  # POST /ticket_types
  # POST /ticket_types.json
  def create
    if params[:ticket_type]
      @ticket_type = TicketType.new(params[:ticket_type])
      
    else
     # from = params[:sell_from].split('/')
     # to = params[:sell_to].split('/')

     # sell_from = Date.new(from[3].to_i, from[0].to_i, from[1].to_i)
     # sell_to = Date.new(to[3].to_i, to[0].to_i, to[1].to_i)

      params.delete('action')
      params.delete('controller')
      params.delete('sell_from')
      params.delete('sell_to')
      @ticket_type = TicketType.new(params)  
    end

    @ticket_type.is_deleted = false
    unless @ticket_type.capacity
      @ticket_type.capacity = 0
    end

    respond_to do |format|
      if @ticket_type.save
        format.html { redirect_to "/events/#{@ticket_type.event_id}/edit"}
        format.mobile { redirect_to "/events/#{@ticket_type.event_id}/edit"}
        format.json { render json: @ticket_type, status: :created, location: @ticket_type }
      else
        format.html { render action: "new" }
        format.mobile { render action: "new" }
        format.json { render json: @ticket_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /ticket_types/1
  # PUT /ticket_types/1.json
  def update
    @ticket_type = TicketType.find(params[:id])

    unless params[:capacity]
      params[:capacity] = 0
    end
    unless params[:group_size]
      params[:group_size] = 0
    end

    params.delete('id')
    params.delete('action')
    params.delete('controller')

    respond_to do |format|
      if @ticket_type.update_attributes(params)
        format.html { redirect_to "/events/#{@ticket_type.event_id}/edit"}
        format.mobile { redirect_to "/events/#{@ticket_type.event_id}/edit"}
        format.json { render json: @ticket_type }
      else
        format.html { render action: "edit" }
        format.mobile { render action: "edit" }
        format.json { render json: @ticket_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ticket_types/1
  # DELETE /ticket_types/1.json
  def destroy
    @ticket_type = TicketType.find(params[:id])
    event_id = @ticket_type.event_id
    #@ticket_type.destroy
    @ticket_type.is_deleted = true
    @ticket_type.save

    respond_to do |format|
      format.html { redirect_to "/events/#{@ticket_type.event_id}/edit"}
      format.mobile { redirect_to "/events/#{@ticket_type.event_id}/edit"}
      format.json { head :no_content }
    end
  end
end
