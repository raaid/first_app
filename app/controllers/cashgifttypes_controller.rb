
class CashgifttypesController < ApplicationController

  before_filter :mobilize
  respond_to :html, :js, :mobile, :json

  CASHGIFT_STATUS_UNPAID = "unpaid"
  CASHGIFT_STATUS_PAID = "paid"
  CASHGIFT_STATUS_REFUNDED = "refunded"

  def index
    @event = Event.where(:id => params[:id]).first
    @cash_gift = CashGift.new
    @cashgifts = []
    @cash_description = @event.cg_message

    #@cashgifttypes = Cashgifttype.find_all_by_user_id(@event.user_id)
    @cashgifttypes = Cashgifttype.where(:event_id => params[:id])
    #@cashgifttypeswhere = Cashgifttype.where(:user_id => @event.user_id, :shown => TRUE)
    if current_user then
      #@cashgifts = CashGift.where(:user_id => current_user.id, :status => "paid")
      @cash_gift.guest_id = current_user.id
    end
    @cash_gift.guest_email = current_user ? current_user.email : ""
    @cash_gift.guest_name = current_user ? current_user.display_name : ""
    @cash_gift.status = CASHGIFT_STATUS_UNPAID
    @cash_gift.user_id = @event.user_id

    if current_user then
    @cashgifttypes.each do |x|
      cgs = CashGift.where(:user_id => current_user.id, :status => "paid", :cashgifttype_id => x.id)
      cgs.each do |y|
        @cashgifts << y
      end
    end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.mobile # index.html.erb
      format.json { render json: @cashgifttypes }
    end
  end

  # GET /cashgifttypes/1
  # GET /cashgifttypes/1.json
  def show
    @cashgifttype = Cashgifttype.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.mobile # show.html.erb
      format.json { render json: @cashgifttype }
    end
  end

  # GET /cashgifttypes/new
  # GET /cashgifttypes/new.json
  def new
    @event  = Event.where(:id => params[:id]).first
    @cg = false
    if params[:cg] == "1"
      @cg = true
    end

    @cashgifttype = Cashgifttype.new
    @cashgifttype.currency = 'CAD'
    @cashgifttype.event_id = @event.id

    if @cg
      @cashgifttype.is_donation = false
    else
      @cashgifttype.is_donation = true
    end

    respond_to do |format|
      format.html # new.html.erb
      format.mobile # show.html.erb
      format.json { render json: @cashgifttype }
    end
  end

  # GET /cashgifttypes/1/edit
  def edit
    @cashgifttype = Cashgifttype.find(params[:id])
    @cg = false
    unless @cashgifttype.is_donation
      @cg = true
    end
  end

  # POST /cashgifttypes
  # POST /cashgifttypes.json
  def create
    
    if params[:is_donation]
      params.delete("action")
      params.delete("controller")
      @cashgifttype = Cashgifttype.new(params)
    else
      @cashgifttype = Cashgifttype.new(params[:cashgifttype])
    end
    @cashgifttype.shown = TRUE
    @cashgifttype.user_id = current_user.id
    @event = Event.where(:id => @cashgifttype.event_id).first
    respond_to do |format|
      if @cashgifttype.save
        format.html { redirect_to "/events/#{@cashgifttype.event_id}/edit", notice: 'Your Option Was Successfully Added To This Event.' }
        format.mobile { redirect_to "/events/#{@cashgifttype.event_id}/edit", notice: 'Your Option Was Successfully Added To This Event.' }
        format.json { render json: {
          id:@cashgifttype.id,
          description:@cashgifttype.description,
          title:@cashgifttype.title,
          shown:@cashgifttype.shown,
          goal:@cashgifttype.goal,
          url: @cashgifttype.cgp_url(:newsfeed)

          }, status: :created, location: @cashgifttype }
      else
        format.html { render action: "new", alert: @cashgifttype.errors.full_messages[0] }
        format.mobile { render action: "new" }
        format.json { render json: @cashgifttype.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /cashgifttypes/1
  # PUT /cashgifttypes/1.json
  def update
    @cashgifttype = Cashgifttype.find(params[:id])

    params.delete('action')
    params.delete('controller')
    params.delete('id')

    respond_to do |format|
      if @cashgifttype.update_attributes(params)
        format.html { redirect_to "/events/#{@cashgifttype.event_id}/edit", notice: 'Your Option Was Successfully Updated.' }
        format.mobile { redirect_to "/events/#{@cashgifttype.event_id}/edit", notice: 'Your Option Was Successfully Updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.mobile { render action: "edit" }
        format.json { render json: @cashgifttype.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cashgifttypes/1
  # DELETE /cashgifttypes/1.json
  def destroy
    @cashgifttype = Cashgifttype.find(params[:id])
    @cashgifttype.destroy

    respond_to do |format|
      format.html { redirect_to events_path }
      format.mobile { redirect_to events_path }
      format.json { head :no_content }
    end
  end
end
