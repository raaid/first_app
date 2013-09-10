
class InvitationMessagesController < ApplicationController

  before_filter :mobilize
  respond_to :html, :js, :mobile, :json

  layout 'invitation_layout', only: [:show]

  def index
    @invitation_messages = InvitationMessage.find_all_by_owner_id(current_user.id)
    @event = Event.find(params[:event_id])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @invitation_messages }
    end
  end

  # GET /invitation_messages/1
  # GET /invitation_messages/1.json
  def show
    @invitation_message = InvitationMessage.find(params[:id])
    @owner = User.find(@invitation_message.owner_id)
    
    
    if @invitation_message.video
      @video_html = opentok_video_html(@invitation_message.video)
    else
      @video_html = ""
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @invitation_message }
    end
  end

  # GET /invitation_messages/new
  # GET /invitation_messages/new.json
  def new
    @invitation_message = InvitationMessage.new
    @invitation_message.owner_id = current_user.id
    @event = Event.find(params[:event_id])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @invitation_message }
    end
  end

  # GET /invitation_messages/1/edit
  def edit
    @invitation_message = InvitationMessage.find(params[:id])
    @event = Event.find(params[:event_id])
  end

  # POST /invitation_messages
  # POST /invitation_messages.json
  def create
    @invitation_message = InvitationMessage.new(params[:invitation_message])
    @invitation_message.owner_id = current_user.id

    respond_to do |format|
      if @invitation_message.save
        #puts "VID: #{@invitation_message.video}"
        if @invitation_message.video and not @invitation_message.video == ""
          # Start transcoding
          transcode_flv(opentok_flv_url(@invitation_message.video), @invitation_message.video)
        end

        format.html { redirect_to rsvp_path(:id => params[:invitation_message][:event_id]), notice: 'Invitation message was successfully created.' }
        format.json { render json: @invitation_message, status: :created, location: @invitation_message }
      else
        format.html { render action: "new" }
        format.json { render json: @invitation_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /invitation_messages/1
  # PUT /invitation_messages/1.json
  def update
    @invitation_message = InvitationMessage.find(params[:id])
    old_video = @invitation_message.video

    respond_to do |format|
      if @invitation_message.update_attributes(params[:invitation_message])
        # Start transcoding
        if params[:invitation_message][:video] and not params[:invitation_message][:video] == ""
          transcode_flv(opentok_flv_url(@invitation_message.video), @invitation_message.video)
        end

        format.html { redirect_to invitation_messages_path(:event_id => params[:invitation_message][:event_id]), notice: 'Invitation message was successfully updated.' }
        format.json { render json: true }
      else
        format.html { render action: "edit" }
        format.json { render json: @invitation_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invitation_messages/1
  # DELETE /invitation_messages/1.json
  def destroy
    @invitation_message = InvitationMessage.find(params[:id])
    @invitation_message.destroy

    respond_to do |format|
      format.html { redirect_to invitation_messages_path(:event_id => params[:event_id]) }
      format.json { render json: true }
    end
  end
end
