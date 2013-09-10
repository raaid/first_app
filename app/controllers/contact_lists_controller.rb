class ContactListsController < ApplicationController

  before_filter :mobilize
  respond_to :html, :js, :mobile, :json

  def index
    @contact_lists = ContactList.where(:owner_id=>current_user.id,:admin=>false )
    @event = Event.find(params[:event_id])
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @contact_lists }
    end
  end

  # GET /contact_lists/1
  # GET /contact_lists/1.json
  def show
    @contact_list = ContactList.find(params[:id])
    #@contact_list = @contact_list.contact_list_members.sort!{|b,a|b.name <=> a.name}
    @event = Event.find(params[:event_id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @contact_list }
    end
  end

  # GET /contact_lists/new
  # GET /contact_lists/new.json
  def new
    @contact_list = ContactList.new
    @contact_list.owner_id = current_user.id

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @contact_list }
    end
  end

  # GET /contact_lists/1/edit
  def edit
    @contact_list = ContactList.find(params[:id])
  end

  # POST /contact_lists
  # POST /contact_lists.json
  def create
    @contact_list = ContactList.new(params[:contact_list])
    @contact_list.owner_id = current_user.id
    @contact_list.admin = false
    respond_to do |format|
      if @contact_list.save
        format.html { redirect_to @contact_list, notice: 'Contact list was successfully created.' }
        format.json { render json: @contact_list, status: :created, location: @contact_list }
      else
        format.html { render action: "new" }
        format.json { render json: @contact_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /contact_lists/1
  # PUT /contact_lists/1.json
  def update
    @contact_list = ContactList.find(params[:id])
    @contact_list.owner_id = current_user.id


    respond_to do |format|
      if @contact_list.update_attributes(params[:contact_list])
        format.html { redirect_to @contact_list, notice: 'Contact list was successfully updated.' }
        format.json { render json: true }
      else
        format.html { render action: "edit" }
        format.json { render json: @contact_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contact_lists/1
  # DELETE /contact_lists/1.json
  def destroy
    @contact_list = ContactList.find(params[:id])
    @contact_list.destroy

    respond_to do |format|
      format.html { redirect_to contact_lists_path(:event_id => params[:event_id]) }
      format.json { render json: true }
    end
  end

  # POST /contact_lists/1/send_message
  def send_message
    Resque.enqueue(Jobs::Deliver_invitation_message_email, params[:id], params[:message_id])

    render json: true
  end

  def import_from_google
    redirect_to_google_auth(url_for(:action => 'google_callback'))
  end

  def google_callback
    permanent_token = get_permanent_google_token(params[:token])

    if permanent_token
      show_importables(standardize_contacts(get_gmail_contacts(permanent_token)))
    else
      redirect_to root_url, :alert => "There Was An Error In Communication With Google. Please Try Again."
    end
  end

  def standardize_contacts(raw_contacts)
    #puts "standardize_contacts: #{raw_contacts}"
    return raw_contacts.collect do |contact|
      { name: contact['fname'],
        email: contact['email'] }
    end
  end

  def import_from_apple_mail
  end

  def import_from_apple_mail_post
    show_importables(standardize_contacts(get_apple_mail_contacts(params[:vcf].read)))
  end

  def import_from_outlook
  end

  def import_from_outlook_post
    show_importables(standardize_contacts(get_outlook_contacts(params[:csv].read)))
  end

  def import_from_yahoo_post
    show_importables(standardize_contacts(get_yahoo_contacts(params[:csv].read)))
  end

  def import_from_facebook
    # If a Facebook authorization already exists, then go ahead and use it. Otherwise, bounce to facebook.
    @user = current_user
    @authentication = current_user.authentications.find_by_provider('facebook')

    if @authentication
      # @appid = '448543725167738' #wedreg
      @appid = '229422947142229' #localhost
      me = FbGraph::User.me(@authentication.token).fetch
      @friends = me.friends
      @friends.sort! { |a, b| a.name.downcase <=> b.name.downcase }

      friends = []
      @friends.each do |friend|
        if friend
          # BIG PROBLEM: Facebook doesn't give us friends' emails.
          friends << { name: friend.name, email: friend.email }
        end
      end

      show_importables(friends)
    else
      option_string = { redirect_to: contact_lists_url(params[:id]) }
      redirect_to "/auth/facebook?#{option_string.to_query}"
    end
  end

  def show_importables(importable_contacts)
    # params[:id] is the ID of the list to add elements to
    # the view provides a page with all of the entries on it and a button at the bottom to add it.
    @importable_contacts = importable_contacts

    render "import_post"
  end
end
