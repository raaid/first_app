require "blackbook"
require "vpim/vcard"
require "iconv"
require "unicode"
require 'json'
require 'rest-client'

class ResourcesController < ApplicationController

  before_filter :require_no_user, :only => [:affiliates_new]
  before_filter :mobilize
  respond_to :html, :js, :mobile, :json

  def privacy
    @current_user = current_user
    @events = Event.where(:is_private => false, :has_been_deleted => false)
  end

  def contact
  end

  def feedback
  end

  def testimonial
  end

  def contact_us
    username = params[:name]
    email = params[:email]
    phone = params[:phone]
    query = params[:query]
    Notifier.contact_us(username,email,phone,query).deliver
    redirect_to root_path
  end

  def about
    @current_user = current_user
  end

  def terms_of_service
    @events = Event.where(:is_private => false, :has_been_deleted => false)
  end

  def terms_of_service_affiliates
    @events = Event.where(:is_private => false, :has_been_deleted => false)
  end

  def landing_page
    #@events = Event.where(:is_private => false, :has_been_deleted => false).limit(6)
  end

  def rsvp
    if current_user
    #@contact_lists = ContactList.find_all_by_owner_id(current_user.id)
    @contact_lists = ContactList.where(:owner_id => current_user.id, :event_id => params[:id])
    @invitation_messages = InvitationMessage.find_all_by_owner_id(current_user.id)
    @eventID = params[:id]
    else
      redirect_to root_url
    end
  end

  def howitworks
    @events = Event.where(:is_private => false, :has_been_deleted => false)
  end

  def tools
    if @ucss == 1
      @user = User.find(36)
      puts '00000000000000000000000000000000000'
      puts '00000000000000000000000000000000000'
      puts '00000000000000000000000000000000000'
      puts '00000000000000000000000000000000000'
      puts '00000000000000000000000000000000000'
      puts @user.id
    else
      @user = current_user
    end

    @widget_profile = @user.widget_profile
    @events = Event.find_all_by_referrer(@user.id)
  end

   # def whitepages_lookup
 #   config = YAML.load_file("#{Rails.root}/config/yellowpages.yml")
 #   WhitePages.api_key = config["production"]["whitepages"]
 #   dets = WhitePages.find_person(name: current_user.display_name)
 #   @details = dets.listings
 # end

 # def yellowpages_lookup
 #   config = YAML.load_file("#{Rails.root}/config/yellowpages.yml")
 #   @client = YellowApi.new(:apikey => config["production"]["yellowpageswhere"])
 #   @client = YellowApi.new(:apikey => config["production"]["yellowpagessand"], :sandbox_enabled => true)
 #   #my_barber = @client.find_business("barber", "Ottawa").listings.first
 #   #@details = @client.get_business_details(my_barber.address.prov, my_barber.name, my_barber.id)
 # end

  def pricing

  end

  def blog

  end

  def affiliates_new

  end

  def attendee

  end

  def landing1

  end
  def landing2

  end
  def landing3

  end
  def landing4

  end
  def landing5

  end
  def landing6

  end

  def consolidated_terms

  end
end
