class VideosController < ApplicationController

  require 'base64'
  # GET /videos
  # GET /videos.json
  def index
    @videos = Video.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @videos }
    end
  end

  # GET /videos/1
  # GET /videos/1.json
  def show
    @video = Video.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @video }
    end
  end

  # GET /videos/new
  # GET /videos/new.json
  def new
    @video = Video.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @video }
    end
  end

  # GET /videos/1/edit
  def edit    
    @video = Video.find(params[:id])
  end

  # POST /videos
  # POST /videos.json
  def create
    @video = Video.new(event_id: params[:event_id], has_youtube: params[:has_youtube], video: params[:video], youtube: params[:youtube], default: params[:default])

    if params[:has_youtube] == 'false'
      image = StringIO.new(Base64.decode64(params[:poster]))
      image.class.class_eval { attr_accessor :original_filename, :content_type }
      image.original_filename = 'tester.jpg'
      image.content_type = 'image/jpeg'
      @video.poster = image
    end

    respond_to do |format|
      if @video.save
        unless @video.has_youtube
          transcode_flv(opentok_flv_url(@video.video), @video.video)
        end
        format.html { redirect_to @video, notice: 'Video was successfully created.' }
        format.json { render json: @video, status: :created, location: @video }
      else
        format.html { render action: "new" }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /videos/1
  # PUT /videos/1.json
  def update
    @video = Video.find(params[:id])

    if params[:default]
      @all_videos = Video.where(event_id: @video.event_id, default: true)
      @all_videos.each do |vid|
        vid.default = false
        vid.save!
      end
    end

    respond_to do |format|
      if @video.update_attributes(default: params[:default])
        format.html { redirect_to @video, notice: 'Video was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /videos/1
  # DELETE /videos/1.json
  def destroy
    @video = Video.find(params[:id])
    @video.destroy

    respond_to do |format|
      format.html { redirect_to videos_url }
      format.json { head :no_content }
    end
  end
end
