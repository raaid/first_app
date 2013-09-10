class WidgetProfilesController < ApplicationController
  # GET /widget_profiles
  # GET /widget_profiles.json
  def index
    @widget_profiles = WidgetProfile.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @widget_profiles }
    end
  end

  # GET /widget_profiles/1
  # GET /widget_profiles/1.json
  def show
    @widget_profile = WidgetProfile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @widget_profile }
    end
  end

  # GET /widget_profiles/new
  # GET /widget_profiles/new.json
  def new
    @widget_profile = WidgetProfile.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @widget_profile }
    end
  end

  # GET /widget_profiles/1/edit
  def edit
    @widget_profile = WidgetProfile.find(params[:id])
  end

  # POST /widget_profiles
  # POST /widget_profiles.json
  def create
    @widget_profile = WidgetProfile.new(params[:widget_profile])

    respond_to do |format|
      if @widget_profile.save
        format.html { redirect_to @widget_profile, notice: 'Widget profile was successfully created.' }
        format.json { render json: @widget_profile, status: :created, location: @widget_profile }
      else
        format.html { render action: "new" }
        format.json { render json: @widget_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /widget_profiles/1
  # PUT /widget_profiles/1.json
  def update
    @widget_profile = WidgetProfile.find(params[:id])

    if params[:tickets_background]
      @widget_profile.tickets_background = params[:tickets_background]
    end
    if params[:events_background]
      @widget_profile.events_background = params[:events_background]
    end

    respond_to do |format|
      if @widget_profile.save
        format.html { redirect_to @widget_profile, notice: 'Widget profile was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @widget_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /widget_profiles/1
  # DELETE /widget_profiles/1.json
  def destroy
    @widget_profile = WidgetProfile.find(params[:id])
    @widget_profile.destroy

    respond_to do |format|
      format.html { redirect_to widget_profiles_url }
      format.json { head :no_content }
    end
  end
end
