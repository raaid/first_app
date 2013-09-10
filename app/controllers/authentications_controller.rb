class AuthenticationsController < ApplicationController

  before_filter :mobilize
  respond_to :html, :js, :mobile, :json

  def index
    @authentications = current_user.authentications if current_user
  end

  def create
    params = request.env['omniauth.params']
    omniauth = request.env['omniauth.auth']
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])

    if authentication
      # Make sure we have the latest authentication token for user
      if omniauth['credentials']['token'] && omniauth['credentials']['token'] != authentication.token
        authentication.update_attribute(:token, omniauth['credentials']['token'])
      end
      # User is already registered with application
      sign_in_and_redirect(authentication.user_id)
    elsif current_user
      # User is signed in but has not already authenticated with this social network
      creds = omniauth['credentials']
      tauth = current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'], :token => omniauth['credentials']['token'], :secret => omniauth['credentials']['secret'])
      message = "#{current_user.display_name}" + ' is now using Ticketacular!'
      description = 'Ticketacular is an awesome service!'
      if omniauth['provider'] == "facebook"
       # me = FbGraph::User.me(creds['token']).fetch
       # me.feed!(:message => message,:link => 'http://www.theweddingregistry.me',:name => 'The Wedding Registry',:description => description)
      end
      current_user.save
      flash[:info] = 'Authentication successful.'
      redirect_to authentications_url
    else
    #Case where user is new,maybe add create account by auth creds here
      me = FbGraph::User.me(omniauth['credentials']['token']).fetch
      email =  me.email
      u =  User.find_by_email(me.email)
      if u
      creds = omniauth['credentials']
      tauth = u.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'], :token => omniauth['credentials']['token'], :secret => omniauth['credentials']['secret'])
      u.save
      sign_in_and_redirect(tauth.user_id) and return
      else
        user = User.create(email: Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )[0, 8]+"@temp.com", password: "password", password_confirmation: "password", fname: "temp")
        user.save
        session = Session.create(user.id)
        user.authentications.new(:provider => omniauth['provider'], :uid => omniauth['uid'], :token => omniauth['credentials']['token'], :secret => omniauth['credentials']['secret'])
        user.save
        user.fname = me.name.split.first
        user.lname = me.name.split.last
        user.email = me.email
        user.gender = me.gender
        #birthday = me.birthday
        #user.birthday = Chronic.parse(birthday) if birthday
        pictureurl = me.picture+'?type=large'
        begin
          tempfile = Tempfile.new(['', '.jpg'])
          open(tempfile.path, 'wb') do |file|
            file << open(URI.parse(pictureurl)).read
          end
          user.avatar = tempfile
        rescue
        end
        user.save
      end

      respond_to do |format|
          format.html { redirect_to root_url }
      end
    end
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    redirect_to :back
  end

  # This is necessary since Rails 3.0.4 See https://github.com/intridea/omniauth/issues/185
  def handle_unverified_request
    true
  end

  def sign_in_and_redirect(id)
    unless current_user
      @session = Session.create(User.find_by_id(id))
    end

    if params[:redirect_to]
      redirect_to params[:redirect_to]
    else
      redirect_to root_url
    end
  end

  #Use show as the method to import profile information from social media source
  def show()
    @authentication = Authentication.find(params[:id])

    if @authentication.provider == "facebook"
      me = FbGraph::User.me(@authentication.token).fetch
      current_user.fname = me.name.split.first
      current_user.lname = me.name.split.last
      current_user.email = me.email
      current_user.gender = me.gender
      birthday = me.birthday
      current_user.birthday = Chronic.parse(birthday) if birthday

      location = me.location
      current_user.location = location if location and location.is_a? String
      current_user.location = location.try(:[], :name) if location and location.is_a? Hash
      pictureurl = me.picture+'?type=large'
      begin
        tempfile = Tempfile.new(['', '.jpg'])
        open(tempfile.path, 'wb') do |file|
          file << open(URI.parse(pictureurl)).read
        end
        current_user.avatar = tempfile
      rescue
      end
    end

    current_user.save
    redirect_to edit_user_path
  end

  def failure
    redirect_to root_url, :flash => {:error => "Could not log you in."}
  end

  def invite_facebook

    @authentication = current_user.authentications.find_by_provider('facebook')
    @user = current_user
    @appid = '448543725167738' #wedreg
    #@appid = '229422947142229' #localhost
    me = FbGraph::User.me(@authentication.token).fetch
    @friends = me.friends
    @friends.sort! { |a, b| a.name.downcase <=> b.name.downcase }
    @a = []
    @friends.each do |friend|
      @a.push(friend.identifier.to_i)

    end
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @authentication }
    end
  end
end
