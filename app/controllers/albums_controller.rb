class AlbumsController < ApplicationController

  before_filter :mobilize
  respond_to :html, :js, :mobile, :json

  def index
    @albums = Album.find_all_by_event_id(params[:u_id])
    @live

    @albums.each do |album|
      if album.name == 'twrlive'
        @live = album
      end
    end

    if not @live
      liveAlbum = Hash.new
      liveAlbum[:name] = 'twrlive'
      liveAlbum[:user_id] = params[:u_id]
      @live = Album.new(liveAlbum)
      @live.save!

    end

    @user = User.find_by_id(params[:u_id])
    @first_photos = []
    @albums.each do |album|      
      pic = AlbumPhoto.find_by_album_id(album.id)
      if pic
        @first_photos << pic
      else
        @first_photos << ""
      end
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @albums }
    end
  end

  # GET /albums/1
  # GET /albums/1.json
  def show
    @events = Event.all
    @album = Album.find(params[:id])
    @album_photo = AlbumPhoto.new
    @allphotos = AlbumPhoto.find_all_by_album_id(params[:id])
    @photos = []
    @user = User.where(:id=>(Event.where(:id => @album.event_id).first).user_id).first
    @allphotos.each do |photo|
      if (photo.approved == 1)
        @photos.push(photo)
      end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.mobile
      format.json { render json: @album }
    end
  end

  # GET /albums/new
  # GET /albums/new.json
  def new
    @album = Album.new
    @user = current_user

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @album }
    end
  end

  # GET /albums/1/edit
  def edit
    @album = Album.find(params[:id])
    @album_photo = AlbumPhoto.new
    @album_photo.album_id = @album.id.to_i
    @album_photo.approved = 0
    respond_to do |format|
      format.html # edit.html.erb
  #    format.mobile_p # edit.html.erb
      format.json { render json: @album }
    end
  end

  # POST /albums
  # POST /albums.json
  def create
    @album = Album.new(params[:album])

    respond_to do |format|
      if @album.save
        format.html { redirect_to @album, notice: 'Album was successfully created.' }
        format.json { render json: @album, status: :created, location: @album }
      else
        format.html { render action: "new" }
        format.json { render json: @album.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /albums/1
  # PUT /albums/1.json
  def update
    @album = Album.find(params[:id])

    respond_to do |format|
      if @album.update_attributes(params[:album])
        format.html { redirect_to @album, notice: 'Album was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @album.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /albums/1
  # DELETE /albums/1.json
  def destroy

    @album = Album.find(params[:id])
    @photos = AlbumPhoto.find_all_by_album_id(params[:id])

    @photos.each do |photo|
      photo.destroy
    end

    @album.destroy

    respond_to do |format|
      format.html { render :json => "removed" }
      format.json { head :no_content }
    end
  end

  def live_stream
    @album = Album.find(params[:id])
    allphotos = AlbumPhoto.find_all_by_album_id(params[:id])

    @photos = []
    allphotos.each do |pic|
      if (pic.approved == 1)
        @photos.push(pic)
      end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @album }
    end
  end

  def choose_images
    @photos = AlbumPhoto.find_all_by_album_id(params[:id])

    respond_to do |format|
      format.html
      format.mobile
      format.json { render json: @album }
    end
  end

  def download_zip
    ids = params["ids"].split(",")
    
    if ids.length > 0
    
      @images = AlbumPhoto.where(id: ids)
      @image_paths = @images.map do |element| element.photo_url(:original) end
      download_photos_as_zip(@image_paths)
      #render json: "ok"
    else
      redirect_to :back, alert: "Please select images to download"
    end
  end

  # Zip code is from http://stackoverflow.com/questions/9908571/downloading-and-zipping-files-that-were-uploaded-to-s3-with-carrierwave
  # works, but creates the zip file, then allows the user to download.  Would be better if we could start sending the file
  # while it's being created.  Look into zip64writer for this:
  # http://geoffyoungs.github.io/blog/2011/09/05/playing-with-zip/
  # or the github repo for zip64writer
  # https://github.com/geoffyoungs/zip64writer

  require 'tmpdir'
  require 'zip/zip'

  def download_photos_as_zip(photos)
    generate_zip(photos) do |zipname, zip_path|
      File.open(zip_path, 'rb') do |zf|  
      #  self.last_modified = Time.now
      #  self.etag = "eventastic"
       # self.response.headers['Content-Length']     
        self.response.headers['Content-Type'] = "application/zip"
        self.response.headers['Content-Disposition'] = "attachment; filename=#{zipname}"
        self.response.body = Enumerator.new do |out|
          while !zf.eof? do
            out << zf.read(4096)
          end
        end
      end
    end
  end

  def generate_zip(photos, &block)
    require 'open-uri'

    temp_dir = Dir.mktmpdir
    #temp_dir = Rails.root.to_s + "/tmp"

    zip_path = File.join(temp_dir, 'export.zip')
    Zip::ZipFile::open(zip_path, true) do |zipfile|
      photos.each do |photo|
        base_name = file_name_part(photo)
        local_path = File.join(temp_dir, base_name)

        File.open(local_path, 'wb') do |fo|
          fo.print open(photo).read
        end

        zipfile.add(base_name, local_path)
      end
    end
    
    #block.call 'export.zip', zip_path
    data = open(zip_path) 
    cookies["download_finished"] = "true"
    send_data data.read, filename: "export.zip", type: "zip", stream: 'false'
        
  ensure
   # FileUtils.rm_rf(Dir.glob(temp_dir + '/*')) 
  end
  
  def file_name_part(full_path)
    full_path.split("/").last
  end
end
