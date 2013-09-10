class UsersController < ApplicationController

  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update, :contacts, :profile, :search]
  before_filter :mobilize
  respond_to :html, :js, :mobile, :json

  def search
    @users = User.search(params['query'])
    #@users.delete_if{|x| x.accounttype != 0}
    respond_to do |format|
      format.html # search.html.erb
      format.json { render json: to_json_search(@users) }
    end
  end

  def to_json_search(users)
    newuser = []
    users.each do |user|
      if user.avatar_file_name.nil?
        image = "http://s3.amazonaws.com/storage.production.giftopia.me/avatar/thumb/missing.jpg"
      else
        image = user.avatar_url(:thumb)
      end
      newuser << {id: user.id,
                  avatar_file_name: image,
                  email: user.email,
                  fname: user.fname,
                  lname: user.lname
      }
    end
    newuser
  end

  def profile
    @user = current_user

    respond_to do |format|
      format.html # profile.html.erb
      format.json { render json: @user.to_json_hash }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user.to_json_hash }
    end
  end

  # GET /users/1/edit
  def edit
    @user = current_user
    @authentications = current_user.authentications if current_user
    respond_to do |format|
      format.html # edit.html.erb
      format.mobile
      format.json { render json: @user.to_json_hash }
    end

  end

  # POST /users
  # POST /users.json
  def create
    @session = Session.create(params[:user])
    redirect_to(root_url) and return if @session.valid?

    @user = User.create(params[:user])
    ref = Rails.cache.read('cached_referrer');

    unless ref == nil
      @user.referred_by = ref
      Rails.cache.delete('cached_referrer')
    end

    @user.role = 'user'
    unless params[:user][:accounttype]
      @user.accounttype = 0
    end
    if @user.fname.blank?
      @user.fname = 'temp'
    end
    Notifier.greet(@user).deliver if @user.valid?

    if params[:user][:accounttype] == "1"
      noticeTxt = "Your application is under review"
      Notifier.request_affiliate_approval(@user).deliver if @user.valid?
      @widget_profile = WidgetProfile.create(:user_id => @user.id, :tickets_background => '#fff', :events_background => '#fff')
    else
      noticeTxt = 'Registration Successful, Welcome Aboard!'
    end

    respond_to do |format|
      if @user.save
        # Store referrer data if present.
     #   referrer = param_or_session :referrer
     #   if referrer then
     #     AffiliateReferral.create! ({ referrer_id: referrer, referree_id: @user.id })
     #   end
        format.html { redirect_to root_path, notice:  noticeTxt}
        format.mobile { redirect_to root_path, notice: noticeTxt }
        format.json { render json: @user, status: :created, location: @user }
      else
        flash[:error] = []
        flash[:error] << @user.errors[:email][0]
        flash[:error] << @user.errors[:password][0]
        format.html { redirect_to root_path, alert: 'There was an error creating your account, please re-enter your information and ensure your password and the password confirmation are matching!' }
        format.mobile { redirect_to new_user_path, alert: 'There was an error creating your account, please re-enter your information and ensure your password and the password confirmation are matching!' }
        format.json { render json: @user.errors }
        # format.json { render json: "problems!" }
      end
    end
  end

  def param_or_session(key)
    result = params[key]
    if result == nil or result.to_s.length == 0 then
      result = session[key]
      if result == nil or result.to_s.length == 0 then
        result = nil
      end
    end

    result
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = current_user
    #Gift.get_image_from_upload_or_url(profile, :avatar, :photourl, weddingprofile.avatar, weddingprofile.avatar_file_name)
    # If the user didn't enter new passwords, then do not attempt to update the user's password.
    if ((not params[:user][:password_confirmation]) || params[:user][:password_confirmation].length == 0)
          params[:user].delete(:password)
          params[:user].delete(:password_confirmation)
        end

        if @user.accounttype == 0
        unless params[:cg_key_confirm] == params[:user][:cg_key2]
          redirect_to :back, alert: "Security answer and confirmed answer must match"
          return
        end

        if params[:cg_key_old] != nil
          unless params[:cg_key_old] == @user.cg_key2
            redirect_to :back, alert: "Current answer must match the currently set security answer"
            return
          end
        end

        if xor(params[:user][:cg_key1].length == 0, params[:user][:cg_key2].length == 0)
          redirect_to :back, alert: "Please fill out the security question with an answer"
          return
        end
        end
    
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.js { respond_with(@user) }
        format.html { redirect_to root_path, notice: 'Congratulations! You Successfully Updated Your Profile.' }
        format.mobile { redirect_to root_path, notice: 'Congratulations! You Successfully Updated Your Profile.' }
        format.json { head :no_content }
      else
        format.js { respond_with(@user) }
        format.html { render action: "edit" }
        format.mobile { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy

    @user = current_user
    @session = Session.find

    @user.has_been_deleted = true
    @user.save
    Notifier.close(@user).deliver if @user.valid?
    @session.destroy
    redirect_to root_url
  end

  def contacts
    @user = current_user
    @users = @user.contacts

    render 'contacts'
  end

  def lists
    @user = User.find(params[:id])
    @contact = @user if current_user != @user

  unless @user.lists.find {|list| list[:name] == 'Cash Gifts'}
     List.create!(user_id: @user.id, access: List::ADMIN, name: 'Cash Gifts')
   end
  unless Cashgiftsprofile.find_by_user_id(@user.id)
     Cashgiftsprofile.create!(user_id: @user.id)
  end
   #@cashgiftsprofile = Cashgiftsprofile.find_by_user_id(@user.id)

    #@lists = @user.lists.user
    #@lists << @user.lists.public
    #@suggestionsList = @user.lists.suggested


    @lists = []
    # @user.user_lists.where(user_id: params[:id]).each do |list|
    #   @lists << list
    # end
    # @lists << @user.lists.public
    @suggestionsList = @user.lists.suggested

    if current_user
      memberships = Membership.find_all_by_user_id(current_user.id)
      memberships.each do |membership|
        @user.lists.each do |list|
          if membership.list_id == list.id
            @lists << list
          end
        end
      end
    end
    @lists << @user.lists.public
    unless @user.lists.find {|list| list[:name] == 'Cash Gifts'}
     List.create!(user_id: @user.id, access: List::ADMIN, name: 'Cash Gifts')
    end
    @cashgifts = @user.lists.cash_gifts


    respond_to do |format|
      format.html { respond_with(@contact) }
      format.json { head :no_content }
    end
  end

  def checkSecurityAnswer
    @user= User.find(params[:id])
    data = false

    if params[:answer] == @user.cg_key2
      data = true
    end
    
    render json: data
  end

  def dashboard
    @data = []
    #@events = Event.find_all_by_referrer(current_user.id)
    @events = Event.where("referrer = ? and has_ticketing = true", current_user.id)
    @grand_total_amount = 0
    @grand_total_to_be_cashed = 0


    @events.each do |event|

      ticket_types = TicketType.find_all_by_event_id(event.id)
      types = []
      totalAmount = 0
      to_be_cashed = 0

      ticket_types.each do |type|
        
        tickets = TicketInstance.where("ticket_type_id = ? AND (status = 'paid' OR status = 'redeemed')", type.id)
        count = 0
        amount = 0
        fee = getFee(type.price)


        tickets.each do |ticket|
          count += ticket.quantity
          amount += fee * (current_user.negotiated_commission_rate/100)
          unless ticket.payout_affiliate_transaction_id
            to_be_cashed += fee * (current_user.negotiated_commission_rate/100)
          end
        end
        totalAmount += amount

        types << {
          :id => type.id,
          :name => type.name,
          :price => type.price,
          :count => count,
          :amount => amount
        }
      end

      @grand_total_amount += totalAmount
      @grand_total_to_be_cashed += to_be_cashed
      @data << {
        :id => event.id,
        :name => event.name,
        :date => event.startTime.strftime("%Y-%m-%d"),
        :total_amount => totalAmount,
        :to_be_cashed => to_be_cashed,
        :ticket_types => types
      }
    end
  end

  def getFee(price)
    process_fee = 0

    if price < 5
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

  def xor(a,b)
    (a and (not b)) or ((not a) and b)
  end
end
