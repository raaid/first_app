class AttachedsController < ApplicationController
  before_filter :mobilize
  respond_to :html, :js, :mobile, :json

  # GET /attacheds
  # GET /attacheds.json
  def index
    @attacheds = Attached.find_all_by_event_id(params[:e_id])
    @event = Event.find(params[:e_id])
    @attached = Attached.new

    respond_to do |format|
      format.html # index.html.erb
      format.mobile
      format.json { render json: @attacheds }
    end
  end

  # GET /attacheds/1
  # GET /attacheds/1.json
  def show
    @document = Attached.find(params[:id])

    rootString = root_url.to_s.gsub("?locale=", "")

    if request.referer
      if request.referer.include?(rootString + "events/" + @document.event_id.to_s) or request.referer.include?(rootString + "manage_attached/" + @document.event_id.to_s)
        data = open(@document.attached_url(:original)) 
        send_data data.read, filename: @document.attached_file_name, type: @document.attached_content_type, disposition: 'inline', stream: 'true'
        return
      end
    end
      
    redirect_to root_url, alert: "This document can only be viewed through the event page"
    
  end

  # GET /attacheds/new
  # GET /attacheds/new.json
  def new
    @attached = Attached.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @attached }
    end
  end

  # GET /attacheds/1/edit
  def edit
    @attached = Attached.find(params[:id])
  end

  # POST /attacheds
  # POST /attacheds.json
  def create

    @event = Event.find(params[:event_id])
    file = {}

    if params[:flash]
      file["name"] = params[:Filedata].original_filename
      
      extname = File.extname(params[:Filedata].original_filename)[1..-1]
      mime_type = Mime::Type.lookup_by_extension(extname)
      params[:Filedata].content_type = mime_type.to_s unless mime_type.nil?

      file["attached"] = params[:Filedata]
    else
      file["name"] = params[:attached].original_filename
      file["attached"] = params[:attached]
    end

    file["event_id"] = @event.id
    @attached = Attached.new(file)
    

    respond_to do |format|
      if @attached.save
        format.html { redirect_to @event, notice: 'File was successfully uploaded.' }
        format.json { render json: @attached, status: :created, location: @attached }
      else
        format.html { render action: "edit"}
        format.json { render json: @attached.errors, status: :unprocessable_entity }
      end
    end
  end

  def upload_multiple
    allSaved = 0
    @event = Event.find(params[:attached][:event_id])
    error = ""
    params[:attached].each do |key, val|
      if key.to_s != "event_id" and key.to_s != "multiple"
        file = {}
        file["name"] = params[:attached][key].original_filename
        file["attached"] = params[:attached][key]
        file["event_id"] = @event.id
        @attached = Attached.new(file)
        if not @attached.save
          allSaved = 1
          break
        end
      end
    end

    respond_to do |format|
      if allSaved == 0
        format.html { redirect_to "/manage_attached/" + @event.id.to_s, notice: 'Files were successfully uploaded.' }
        format.mobile { redirect_to "/manage_attached/" + @event.id.to_s, notice: 'Files were successfully uploaded.' }
        format.json { render json: @attached, status: :created, location: @attached }
      else
        format.html { render action: "edit", error: @attached.errors}
        format.mobile { render action: "edit", error: @attached.errors}
        format.json { render json: @attached.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /attacheds/1
  # PUT /attacheds/1.json
  def update
    @attached = Attached.find(params[:id])

    respond_to do |format|
      if @attached.update_attributes(params[:attached])
        format.html { redirect_to @attached, notice: 'Attached was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @attached.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /attacheds/1
  # DELETE /attacheds/1.json
  def destroy
    @attached = Attached.find(params[:id])
    @event = Event.find(@attached.event_id)
    @attached.destroy

    respond_to do |format|
      format.html { redirect_to "/manage_attached/" + @event.id.to_s }
      format.json { head :no_content }
    end
  end

end
