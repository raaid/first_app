class AlbumPhotosController < ApplicationController

  before_filter :mobilize
  respond_to :html, :js, :mobile, :json

  def index
    @album_photos = AlbumPhoto.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @album_photos }
    end
  end

  def show
    @album_photo = AlbumPhoto.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @album_photo }
    end
  end

  def new
    @album_photo = AlbumPhoto.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @album_photo }
    end
  end

  def edit
    @album_photo = AlbumPhoto.find(params[:id])
  end

  def create

    if params[:Filedata]
      extname = File.extname(params[:Filedata].original_filename)[1..-1]
      mime_type = Mime::Type.lookup_by_extension(extname)
      params[:Filedata].content_type = mime_type.to_s unless mime_type.nil?
      @album_photo = AlbumPhoto.new(:album_photo => params[:Filedata], :album_id => params[:album_id])
    elsif params[:ajax]
      params["album_photo"] = {}
      params["album_photo"]["album_photo"] = params[:photo]
      params["album_photo"]["album_id"] = params[:id]
      @album_photo = AlbumPhoto.new(params[:album_photo])
    elsif params[:flash]
      params["album_photo"] = {}

      extname = File.extname(params[:Filedata].original_filename)[1..-1]
      mime_type = Mime::Type.lookup_by_extension(extname)
      params[:Filedata].content_type = mime_type.to_s unless mime_type.nil?

      params["album_photo"]["album_photo"] = params[:Filedata]
      params["album_photo"]["album_id"] = params[:id]
      @album_photo = AlbumPhoto.new(params[:album_photo])
    else
      @album_photo = AlbumPhoto.new(params[:album_photo])
    end
    
    
    album = Album.find(@album_photo.album_id)
    @album_photo.approved = 0
    event = Event.find(album.event_id)
    owner = User.find(event.user_id)
    if current_user
      if (current_user.id.to_s == event.user_id.to_s)
        @album_photo.approved = 1
      end
    end

    if (event.auto_approve_photos == true)
      @album_photo.approved = 1
    end

    photoURL = @album_photo.photo_url(:original)

    respond_to do |format|
      if @album_photo.save
          @album_photo["url"] = @album_photo.photo_url(:display)
          format.html { redirect_to event_path(Album.find(@album_photo.album_id).event_id)}
          format.mobile { redirect_to event_path(event.id) }
          format.json { render json: @album_photo}
      else
        format.html { render action: "new" }
        format.json { render json: @album_photo.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @album_photo = AlbumPhoto.find(params[:id])

    respond_to do |format|
      if @album_photo.update_attributes(params[:album_photo])
        format.html { redirect_to @album_photo, notice: 'Album photo was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @album_photo.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @album_photo = AlbumPhoto.find(params[:id])
    @album_photo.destroy

    respond_to do |format|
      format.html { render :json => params[:id] }
      format.mobile { render :json => params[:id] }
      format.json { head :no_content }
    end
  end

  def approve
    @photo = AlbumPhoto.find(params[:id])
    @photo.approved = 1
    @photo.save!

    #photo["url"] = photo.photo_url(:original)
    render :json => @photo
  end

  def update_stream
    @album = Album.find(params[:id])
    allphotos = AlbumPhoto.find_all_by_album_id(params[:id], :order => 'id')
    
    @photos = []
    allphotos.each do |pic|
      if (pic.approved == 1)
        @photos.push(pic)
      end
    end

    sources = []
    sources[0] = 0

    if (@photos.length > params[:length].to_i)
      diff = @photos.length - params[:length].to_i
      sources[0] = diff

      (0..diff).each do |i|
        sources.push(@photos[@photos.length - i - 1].photo_url(:original))
      end

    end

    render :json => sources
  end

  def update_stream2
    @album = Album.find(params[:id])
    allphotos = AlbumPhoto.find_all_by_album_id(params[:id], :order => 'id')

    @photos = []
    allphotos.each do |pic|
      if (pic.approved == 1)
        @photos.push(pic)
      end
    end

    sources = []
    sources[0] = 0

    if (@photos.length > params[:length].to_i)
      diff = @photos.length - params[:length].to_i
      sources[0] = diff

      (0..diff).each do |i|
        if (@photos[@photos.length - i - 1])
        if (@photos[@photos.length - i - 1].photo_url(:display))
          sources.push(@photos[@photos.length - i - 1].photo_url(:display))
        end
        end
      end

    end

    render :json => sources
  end

  def download
    ids = params["ids"].split(",")
    @images = AlbumPhoto.where(id: ids)
    @image_paths = @images.map do |element| element.photo_url(:cover) end
    download_photos_as_zip(@image_paths)
    render json: "ok"
  end

  # Zip code is from http://stackoverflow.com/questions/9908571/downloading-and-zipping-files-that-were-uploaded-to-s3-with-carrierwave
  require 'tmpdir'
  require 'zip/zip'
  # action method, stream the zip
  def download_photos_as_zip(photos) # silly name but you get the idea
    generate_zip(photos) do |zipname, zip_path|
      File.open(zip_path, 'rb') do |zf|
        # you may need to set these to get the file to stream (if you care about that)
        # self.last_modified
        # self.etag
        # self.response.headers['Content-Length']
        self.response.headers['Content-Type'] = "application/zip"
        self.response.headers['Content-Disposition'] = "attachment; filename=#{zipname}"
        self.response.body = Enumerator.new do |out| # Enumerator is ruby 1.9
          while !zf.eof? do
            out << zf.read(4096)
          end
        end
      end
    end
  end

  # Zipfile generator
  def generate_zip(photos, &block)
    require 'tmpdir'
    require 'open-uri'

    # base temp dir

    temp_dir = "/home/brendon/src/theweddingregistry/tmp" #Dir.mktempdir
    # path for zip we are about to create, I find that ruby zip needs to write to a real file
    zip_path = File.join(temp_dir, 'export.zip')
    Zip::ZipFile::open(zip_path, true) do |zipfile|
      photos.each do |photo|
        base_name = file_name_part(photo)
        local_path = File.join(temp_dir, base_name)

        File.open(local_path, 'wb') do |fo|
          puts open(photo).read
          fo.print open(photo).read
        end

        zipfile.add(base_name, local_path)
#        zipfile.get_output_stream(file_name_part(photo)) do |io|
#          io.write photo.read
#        end
      end
    end
    # yield the zipfile to the action
    block.call 'export.zip', zip_path
  ensure
    # clean up the tempdir now!
    #FileUtils.rm_rf temp_dir if temp_dir
  end

  def file_name_part(full_path)
    full_path.split("/").last
  end

  def delete_by_src
    @album_photos = AlbumPhoto.all
    @album_photos.each do |photo|
      if photo.photo_url(:display) == params[:src]
        photo.destroy
        render :json => "removed"
        return
      end
    end
    render :json => "err"
  end

end
