class RegistrationListsController < ApplicationController
  require 'csv'

  before_filter :mobilize
  respond_to :html, :js, :mobile, :json
  def index
    @registration_lists = RegistrationList.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @registration_lists }
    end
  end

  # GET /registration_lists/1
  # GET /registration_lists/1.json
  def show
    @registration_list = RegistrationList.find(params[:id])
    @registration_members = RegistrationMember.where(:registration_list_id =>@registration_list.id)

    respond_to do |format|
      format.html # show.html.erb
      format.mobile # show.html.erb
      format.json { render json: @registration_list }
    end
  end

  # GET /registration_lists/new
  # GET /registration_lists/new.json
  def new
    @registration_list = RegistrationList.new

    respond_to do |format|
      format.html # new.html.erb
      format.mobile # show.html.erb
      format.json { render json: @registration_list }
    end
  end

  # GET /registration_lists/1/edit
  def edit
    @registration_list = RegistrationList.find(params[:id])
  end

  # POST /registration_lists
  # POST /registration_lists.json
  def create
    @registration_list = RegistrationList.new(params[:registration_list])

    respond_to do |format|
      if @registration_list.save
        format.html { redirect_to @registration_list, notice: 'Registration list was successfully created.' }
        format.mobile { redirect_to @registration_list, notice: 'Registration list was successfully created.' }
        format.json { render json: @registration_list, status: :created, location: @registration_list }
      else
        format.html { render action: "new" }
        format.mobile { render action: "new" }
        format.json { render json: @registration_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /registration_lists/1
  # PUT /registration_lists/1.json
  def update
    @registration_list = RegistrationList.find(params[:id])

    respond_to do |format|
      if @registration_list.update_attributes(params[:registration_list])
        format.html { redirect_to @registration_list, notice: 'Registration list was successfully updated.' }
        format.mobile { redirect_to @registration_list, notice: 'Registration list was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.mobile { render action: "edit" }
        format.json { render json: @registration_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /registration_lists/1
  # DELETE /registration_lists/1.json
  def destroy
    @registration_list = RegistrationList.find(params[:id])
    @registration_list.destroy

    respond_to do |format|
      format.html { redirect_to registration_lists_url }
      format.mobile { redirect_to registration_lists_url }
      format.json { head :no_content }
    end
  end

  def downloadCSV
    @registration_list = RegistrationList.find_by_event_id(params[:id])
    @registration_members = RegistrationMember.where(:registration_list_id =>@registration_list.id)
    header = "name,email"
    file = "registration_list.csv"
    CSV.open( file, 'w' ) do |writer|
      writer << ['name','email']
      @registration_members.each do |member|
        writer << [member.name, member.email]
      end
    end
    send_file(file)
  end
end
