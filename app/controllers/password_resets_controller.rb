class PasswordResetsController < ApplicationController
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]
  before_filter :require_no_user
  before_filter :mobilize
  respond_to :html, :js, :mobile, :json

  def new
    render
  end
  
  def create
    #@user = User.find_by_email(params[:email])
    @user = User.find(:first, :conditions => ["lower(email) =?", params[:email].downcase])

    if @user
     # @user.deliver_password_reset_instructions!
      @user.reset_perishable_token!
      Notifier.password_reset_instructions(@user).deliver

      respond_to do |format|
        format.html { redirect_to root_url, notice: "Instructions to reset your password have been emailed to you. Please check your email." }
        format.mobile { redirect_to root_url, notice: "Instructions to reset your password have been emailed to you. Please check your email." }
        format.json { render json: true }
      end
    else
      respond_to do |format|
        format.html { render :action => :new, alert: "No user was found with that email address." }
        format.mobile { render :action => :new, alert: "No user was found with that email address." }
        format.json { render json: @user }
      end
    end
  end
  
  def edit
    render
  end

  def update
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      redirect_to root_url, notice: "Password successfully updated"
    else
      render :action => :edit
    end
  end

  private
    def load_user_using_perishable_token
      @user = User.find_by_perishable_token(params[:id])

      unless current_user
        if @user
          @session = Session.create(User.find_by_id(@user.id))
          redirect_to root_url
        end
      end

      unless @user
        redirect_to root_url, alert: "We're sorry, but we could not locate your account. If you are having issues try copying and pasting the URL from your email into your browser or restarting the reset password process."
      end
    end
end
