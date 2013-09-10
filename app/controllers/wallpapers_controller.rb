class WallpapersController < ApplicationController
  # GET /wallpapers
  # GET /wallpapers.json
  def index
    @wallpapers = Wallpaper.all
    @event = Event.find(9)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @wallpapers }
    end
  end

  # GET /wallpapers/1
  # GET /wallpapers/1.json
  def show
    @wallpaper = Wallpaper.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @wallpaper }
    end
  end

  # GET /wallpapers/new
  # GET /wallpapers/new.json
  def new
    @wallpaper = Wallpaper.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @wallpaper }
    end
  end

  # GET /wallpapers/1/edit
  def edit
    @wallpaper = Wallpaper.find(params[:id])
  end

  # POST /wallpapers
  # POST /wallpapers.json
  def create
    if params[:Filedata]
      extname = File.extname(params[:Filedata].original_filename)[1..-1]
      mime_type = Mime::Type.lookup_by_extension(extname)
      params[:Filedata].content_type = mime_type.to_s unless mime_type.nil?
      @wallpaper = Wallpaper.new(:wallpaper => params[:Filedata], :event_id => params[:event_id])
    else 
      @wallpaper = Wallpaper.new(:event_id => params[:event_id], :wallpaper => params[:wallpaper])
    end

    respond_to do |format|
      if @wallpaper.save
        @wallpaper['url'] = @wallpaper.wallpaper_url(:background)
        format.html { redirect_to @wallpaper, notice: 'Wallpaper was successfully created.' }
        format.json { render json: @wallpaper, status: :created, location: @wallpaper }
        format.js { render }
      else
        format.html { render action: "new" }
        format.json { render json: @wallpaper.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /wallpapers/1
  # PUT /wallpapers/1.json
  def update
    @wallpaper = Wallpaper.find(params[:id])

    respond_to do |format|
      if @wallpaper.update_attributes(params[:wallpaper])
        format.html { redirect_to @wallpaper, notice: 'Wallpaper was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @wallpaper.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wallpapers/1
  # DELETE /wallpapers/1.json
  def destroy
    @wallpaper = Wallpaper.find(params[:id])
    @wallpaper.destroy

    respond_to do |format|
      format.html { redirect_to wallpapers_url }
      format.json { head :no_content }
    end
  end

  def add_theme
    case params[:theme]
      when "themeimg1"
        path = "#{Rails.root}/public/images/theme/theme1.jpg"
      when "themeimg2"
        path = "#{Rails.root}/public/images/theme/theme2.jpg"
      when "themeimg3"
        path = "#{Rails.root}/public/images/theme/theme3.jpg"
      when "themeimg4"
        path = "#{Rails.root}/public/images/theme/theme4.jpg"
    end


    file = StringIO.new(IO.read(path)) #mimic a real upload file
    file.class.class_eval { attr_accessor :original_filename, :content_type } #add attr's that paperclip needs
    file.original_filename = "theme1" #assign filename in way that paperclip likes
    file.content_type = "image/jpeg"

    @wallpaper = Wallpaper.new(:event_id => params[:event_id])
    @wallpaper.wallpaper = file
    @wallpaper.save

    respond_to do |format|
      @wallpaper['url'] = @wallpaper.wallpaper_url(:preview)
      format.html { redirect_to wallpapers_url }
      format.json { render json: @wallpaper, status: :created, location: @wallpaper }
    end
  end
end
