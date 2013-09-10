class InvitationResponsesController < ApplicationController

  before_filter :mobilize
  respond_to :html, :js, :mobile, :json

  def index
    @invitations = Invitation.find_all_by_owner(current_user.id)
    @invitations_sent = []
    @invitations_responses = []
    @invitations.each do |i|
      ir = InvitationResponse.where({invitation_id: i.id}).first
      unless ir.status.blank?
        @invitations_responses << i
      else
        @invitations_sent << i
      end
    end
    @invitations_sent = @invitations_sent.sort!{|b,a|b.name <=> a.name}
    @invitations_responses = @invitations_responses.sort!{|b,a|b.name <=> a.name}
    @event = Event.find(params[:event_id])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @invitation_responses }
    end
  end

  # GET /invitation_responses/1
  # GET /invitation_responses/1.json
  def show
    #@invitation = Invitation.find(params[:id])
    @invitation_response = InvitationResponse.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @invitation_response }
    end
  end

  # GET /invitation_responses/new
  # GET /invitation_responses/new.json
  def new
    @invitation_response = InvitationResponse.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @invitation_response }
    end
  end

  # GET /invitation_responses/1/edit
  def edit
    @invitation = Invitation.find(params[:id])
    @invitation_response = InvitationResponse.where({invitation_id: params[:id]}).first
  end

  # POST /invitation_responses
  # POST /invitation_responses.json
  def create
    @invitation_response = InvitationResponse.new(params[:invitation_response])

    respond_to do |format|
      if @invitation_response.save
        format.html { redirect_to @invitation_response, notice: 'Invitation response was successfully created.' }
        format.json { render json: @invitation_response, status: :created, location: @invitation_response }
      else
        format.html { render action: "new" }
        format.json { render json: @invitation_response.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /invitation_responses/1
  # PUT /invitation_responses/1.json
  def update
    @invitation_response = InvitationResponse.where(:id => params[:id]).first
    @invitation_response.status =  params[:invitation_response]["status"]
    @invitation_response.description =  params[:invitation_response][:description]

    respond_to do |format|
      if @invitation_response.save
        format.html { redirect_to root_url, notice: 'RSVP Response was successfully submitted!' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @invitation_response.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invitation_responses/1
  # DELETE /invitation_responses/1.json
  def destroy
    @invitation_response = existing_response(params[:id])
    @invitation_response.destroy

    respond_to do |format|
      format.html { redirect_to invitation_responses_url }
      format.json { head :no_content }
    end
  end

  def existing_response(id)
    invitation_response = InvitationResponse.where({invitation_id: id}).first
    unless invitation_response
      # If the response doesn't exist, the user hasn't responded yet.
      invitation_response = InvitationResponse.create!({id: id, invitation_id: id})
    end

    return invitation_response
  end
end
