class SessionsController < ApplicationController

  before_filter :require_user, only: [:destroy]
  before_filter :mobilize
  respond_to :html, :js, :mobile, :json

   def show
     @session = Session.find
     respond_to do |format|
      format.json { render :json => !@session.nil? }
     end
   end

   def new
     @session = Session.new
     respond_with(@session)
   end

   def create
    
     if session[:redirect_to] then
       redirect_to_url = session[:redirect_to]
       session.delete :redirect_to
     else
       redirect_to_url = root_url
     end

     if params[:session]
      @session = Session.create(params[:session])
     else
      @session = Session.create(:email => params[:email], :password => params[:password])
     end



     respond_to do |format|
       if current_user

           ref = Rails.cache.read('cached_referrer');
           unless ref == nil
              current_user.referred_by = ref
              current_user.save
              Rails.cache.delete('cached_referrer')
           end

           format.html { redirect_to redirect_to_url}
           format.mobile { redirect_to root_path}

           format.json { render :json => @session }
       else
         format.html { redirect_to root_url, alert: "We couldn't log you in! Please check your username and password." }
         format.mobile { redirect_to root_url, alert: "We couldn't log you in! Please check your username and password." }
         format.json { render :json => @session.errors.empty? }
       end
     end
   end

   def destroy
     @session = Session.find
     @session.destroy
     respond_to do |format|
       format.html { redirect_to root_url}
       format.mobile { redirect_to root_url}
       format.json { render :json => true }
     end
   end
 end
