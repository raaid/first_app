class RegistrationMembersController < ApplicationController
  # GET /registration_members
  # GET /registration_members.json
  def index
    @registration_members = RegistrationMember.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @registration_members }
    end
  end

  # GET /registration_members/1
  # GET /registration_members/1.json
  def show
    @registration_member = RegistrationMember.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @registration_member }
    end
  end

  # GET /registration_members/new
  # GET /registration_members/new.json
  def new
    @registration_member = RegistrationMember.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @registration_member }
    end
  end

  # GET /registration_members/1/edit
  def edit
    @registration_member = RegistrationMember.find(params[:id])
  end

  # POST /registration_members
  # POST /registration_members.json
  def create
    @registration_member = RegistrationMember.new
    @registration_member.name = params[:name]
    @registration_member.email = params[:email]
    @registration_member.message = params[:message]
    @registration_member.registration_list_id = params[:registration_list_id]

    reg_list =  RegistrationList.where(:id => @registration_member.registration_list_id).first
    @event = Event.where(:id=> reg_list.event_id).first
    respond_to do |format|
      if @registration_member.save
        #Notifier.alert_user(user,email,alert_title, alert).deliver
        #format.html { redirect_to @event, notice: 'Registration was successful!' }
        format.html {render :json => @registration_member, notice: 'Registration was successful!' }
        format.json { render json: @registration_member, status: :created, location: @registration_member }
      else
        format.html { redirect_to @event, alert: 'Registration was unsuccessful, please check the email and or name you\'ve entered!' }
        format.json { render json: @registration_member.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /registration_members/1
  # PUT /registration_members/1.json
  def update
    @registration_member = RegistrationMember.find(params[:id])

    respond_to do |format|
      if @registration_member.update_attributes(params[:registration_member])
        format.html { redirect_to @registration_member, notice: 'Registration member was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @registration_member.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /registration_members/1
  # DELETE /registration_members/1.json
  def destroy
    @registration_member = RegistrationMember.find(params[:id])
    @registration_member.destroy

    respond_to do |format|
      format.html { redirect_to registration_members_url }
      format.json { head :no_content }
    end
  end
end
