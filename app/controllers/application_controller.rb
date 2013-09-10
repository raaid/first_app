class ApplicationController < ActionController::Base

  require 'open-uri'

  helper_method :user
  helper_method :authenticated?
  helper_method :mobile?
  helper_method :current_user
  skip_before_filter :verify_authenticity_token
  #before_filter :set_locale
  #before_filter :ucss_login

  before_filter :stash_referrer
 
  #def ucss_login
  #  Session.create(:email => 'bkoms@hotmail.com', :password => 'pass')
  #  @ucss = 1
  #end

  def set_locale

    if params[:locale].blank?
      I18n.locale = extract_locale_from_accept_language_header
    else
      I18n.locale = params[:locale] || I18n.default_locale
    end

#    I18n.locale = params[:locale] || I18n.default_locale
  end

  #def default_url_options(options={})
 #   { :locale => I18n.locale }
  #end

  def extract_locale_from_accept_language_header
    browser_locale = request.env['HTTP_ACCEPT_LANGUAGE'].try(:scan, /^[a-z]{2}/).try(:first).try(:to_sym) 
    if I18n.available_locales.include? browser_locale
      browser_locale
    else
      I18n.default_locale
    end
  end

  #| OpenTok |#
  def opentok_video_html(video_id)
    # For the time being, we'll always use sublime.
#    if not flash_enabled
      # Use SublimeVideo.
      '<video class="sublime" width="525" height="420" preload="none"><source src="' + opentok_mp4_url(video_id) + '"/></video><br /><br />'
#    else
      # Use OpenTok.
#      '<script type="text/javascript" charset="utf-8">$(document).ready(function() { init(); });</script>'
#    end
  end

  def opentok_video_html2(video_id)
    # For the time being, we'll always use sublime.
#    if not flash_enabled
      # Use SublimeVideo.
      event = Event.where(:video => video_id).first
    '<a class="sublime" href="'+opentok_mp4_url(video_id)+'">
      <span class="zoom_icon"></span>
    </a>
    <video id="video1" style="display:none"  class="sublime zoom" width="530" height="420" poster="/images/video-poster.jpg" preload="none" data-settings="overlay-opacity:0.9;close-button-visibility:visible">
      <source src="'+opentok_mp4_url(video_id)+'"/>
    </video><br /><br />'



#    else
      # Use OpenTok.
#      '<script type="text/javascript" charset="utf-8">$(document).ready(function() { init(); });</script>'
#    end
  end

  def opentok_mp4_url(archive_id)
    "https://s3.amazonaws.com/#{AWS_BUCKET}/transcoded_opentok_#{archive_id}.mp4"
  end

  require 'net/https'
  require 'open-uri'

  def opentok_flv_url(archive_id)
    # What we treat as the "video id" for OpenTok is actually the "archive ID". We need both to get the FLV, but video ID can be derived from the archive ID, and the fact that the archive only contains one stream.
    manifest_url = "https://api.opentok.com/hl/archive/getmanifest/#{archive_id}"

    url = URI.parse(manifest_url)
    req = Net::HTTP::Post.new(url.path)
    req.add_field("X-TB-PARTNER-AUTH", "#{OPENTOK_API_KEY}:#{OPENTOK_SECRET_KEY}")

    con = Net::HTTP.new(url.host, url.port)
    con.use_ssl = true
    manifest = con.request(req)

    video_id = nil
    if manifest and manifest.body
      video_id = /<video id=\"([[:graph:]]*)\"/.match(manifest.body)[1]
      
      url = URI.parse("https://api.opentok.com/hl/archive/url/#{archive_id}/#{video_id}")
      req = Net::HTTP::Get.new(url.path)
      req.add_field("X-TB-PARTNER-AUTH", "#{OPENTOK_API_KEY}:#{OPENTOK_SECRET_KEY}")
      
      video_url_response = con.request(req)
      if video_url_response and video_url_response.body
        return video_url_response.body
      end
    end
  end

  require 'open-uri'
  require 'transloadit'

  def transcode_flv(flv_url, video_id)
    result_file_path="transcoded_opentok_#{video_id}.mp4"
    puts "Starting transcoding: #{flv_url} -> #{result_file_path}"

    transloadit = Transloadit.new(:key    => 'b19cf267e6874e8c95729b37bbf71a0d',
                                  :secret => '8b253f36e2674a53cda9c392b8b263a596b16b63')
    
    encode = transloadit.step('encode', '/video/encode', preset: "android")

    store = transloadit.step('store', '/s3/store',
                             key: "AKIAJ5FRHVJPQUZQPPAQ",
                             secret: "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",
                             bucket: "storage.production.giftopia.me",
                             path: result_file_path)

    store = transloadit.step('store', '/s3/store',
                             key: AWS_ACCESS_KEY,
                             secret: AWS_SECRET_KEY,
                             bucket: AWS_BUCKET,
                             path: result_file_path)

    assembly = transloadit.assembly(steps: [encode, store])
    flv_data = open(flv_url)
    response = assembly.submit! flv_data 
  end

  #| Google Integration |#
  def redirect_to_google_auth(redirect)
    # initiate authentication w/ gmail
    # create url with url-encoded params to initiate connection with contacts api
    next_param = redirect
    scope_param = "http%3A%2F%2Fwww.google.com%2Fm8%2Ffeeds%2F"
    secure_param = "0"
    session_param = "1"
    root_url = "https://www.google.com/accounts/AuthSubRequest"
    query_string = "?scope=#{scope_param}&session=#{session_param}&secure=#{secure_param}&next=#{URI::encode(next_param)}"
    redirect_to root_url + query_string
  end

  def get_permanent_google_token(single_use_token)
    #FIRST SINGLE USE TOKEN WILL BE RECEIVED HERE..
    token = single_use_token
    #PREPAIRING FOR SECOND REQUEST WITH AUTH TOKEN IN HEADER.. WHICH WILL BE EXCHANED FOR PERMANENT AUTH TOKEN.
    uri = URI.parse("https://www.google.com")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    path = '/accounts/AuthSubSessionToken'
    headers = {'Authorization' => "AuthSub token=#{token}"}
    #GET REQUEST ON URI WITH SPECIFIED PATH...
    resp = http.get(path, headers)
    #SPLIT OUT TOKEN FROM RESPONSE DATA.
    if resp.code == "200"
      token = ''
      data = resp.body
      data.split.each do |str|
        if not (str =~ /Token=/).nil?
          token = str.gsub(/Token=/, '')
        end
      end

      return token
    else
      return nil
    end
  end

  require 'blackbook'

  def get_gmail_contacts(token)
    @user = current_user
    # GET http://www.google.com/m8/feeds/contacts/default/base
    uri = URI.parse("https://www.google.com")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    path = "/m8/feeds/contacts/default/full?max-results=10000"
    headers = {'Authorization' => "AuthSub token=#{token}",
               'GData-Version' => "3.0"}

    #puts "Requesting: GET #{uri}/#{path}"
    resp = http.get(path, headers)
    data = resp.body
    #puts "Response: #{resp.to_yaml}"

    # extract the name and email address from the response data
    # HERE USING REXML TO PARSE GOOGLE GIVEN XML DATA
    xml = REXML::Document.new(data)
    @importedContacts = []
    xml.elements.each('//entry') do |entry|
      person = {}
      person["fname"] = entry.elements['title'].text
      gd_email = entry.elements['gd:email']
      person["email"] = gd_email.attributes['address'] if gd_email
      if gd_email and entry.elements['title'].text
        person["msg"] = 0
        if !User.find_by_email(person["email"])
          @importedContacts << person
        end
      end
    end
    @emails = []
    @importedContacts.each do |mail|
      @emails.push(mail.fetch('email'))
    end
    @current_user = current_user

    return @importedContacts
  end


  #| Outlook CSV |#
  def get_outlook_contacts(csv_data)
    @user = current_user

    @importedContacts =
      parse_csv_contacts(csv_data) or
      parse_csv_contacts(utf16_to_utf8(csv_data)) or 
      []

    return @importedContacts
  end

  def get_yahoo_contacts(csv_data)
    @user = current_user

    @importedContacts =
      parse_csv_contacts(csv_data) or
      []

    return @importedContacts
  end

  def utf16_to_utf8(str)
    str.force_encoding(Encoding::UTF_16LE)[1..-1].encode(Encoding::UTF_8)
  end

  def parse_csv_contacts(csv_data)
    begin
      temp_file = "/tmp/#{Time.now.to_i.to_s}.csv"
      f = open(temp_file, "wb")
      f.write(csv_data)
      f.close

      contacts = Blackbook.get :csv, :file => open(temp_file)
      @importedContacts = []
      @emails = []
      contacts.each do |entry|
        person = {}

        # Name - Outlook
        person["fname"] = entry[:name]
        if entry[:lname] and not entry[:lname].blank?
          if not person["fname"].blank?
            person["fname"] = "#{person['fname']} "
          end
          person["fname"] = "#{person['fname']}#{entry[:lname]}"
        end

        # Name - Windows Live
      if not person["fname"]
        person["fname"] = ""
        live_fname_key = "\"First Name\"".to_sym
        live_mname_key = "\"Middle Name\"".to_sym
        live_lname_key = "\"Last Name\"".to_sym

        if entry[live_fname_key] and not entry[live_fname_key].blank?
          person["fname"] << " " unless person["fname"].blank?
          person["fname"] << entry[live_fname_key]
        end

        if entry[live_mname_key]
          person["fname"] << " " unless person["fname"].blank?
          person["fname"] << entry[live_mname_key]
        end

        if entry[live_lname_key]
          person["fname"] << " " unless person["fname"].blank?
          person["fname"] << entry[live_lname_key]
        end
      end

        # Email
        person["email"] = entry[:email]
      live_email_key = "\"E-mail Address\"".to_sym
        if person["email"].blank? and entry[live_email_key]
          person["email"] = entry[live_email_key]
        end
        person["email"] = person["email"].tr("\n", "") if person["email"]

        if !person["email"].blank?
          @importedContacts << person
        end
      end

      return @importedContacts
    rescue
      #do nothing
    end
  end

  #| AppleMail VCF |#
  def get_apple_mail_contacts(vcf_data)
    @user = current_user
    begin
      temp_file = "/tmp/#{Time.now.to_i.to_s}.vcf"
      f = open(temp_file, "wb")
      contents = vcf_data
      c = contents.gsub(/[^\x00-\x7F]/n,'')
      f.write(c)
      f.close

      cards = Vpim::Vcard.decode(File.open(temp_file))
      @importedContacts = []
      @emails = []
      cards.each do |card|
        person = {}
        person["fname"] = card.name.formatted
        person["email"] = card.email.to_s
        #person["email"] = person["email"].tr("\n", "") if person["email"]
        if !person["email"].blank?
          #Do not add duplicates
          unless @importedContacts.any? {|h| h["email"] == person["email"]}
            @importedContacts << person
          end
        end
      end
      @importedContacts.each do |mail|
        @emails.push(mail.fetch('email'))
      end
      @importedContacts.sort! { |a, b| a.fetch("fname").downcase <=> b.fetch("fname").downcase }
    rescue
      #do nothing
    end

    return @importedContacts
  end


  #| Facebook  |#


  def numeric?(object)
    true if Float(object) rescue false
  end

  # Crude admin stuff, for now.
  def redirect_non_admins_to
    "/"
  end

  def admin
    user = current_user
    return (user and ["adamkylemorrison@gmail.com", 'bkoms@hotmail.com'].include? user.email)
  end

  def require_admin
    unless require_user and admin
      session[:redirect_to] = request.url
      redirect_to root_path
      return false
    end
    return true
  end

  # Error Messages
  def report_system_error(message)
    # It is not a user error, but we want all the user error handling, plus logging it.
    report_user_error(message)
    puts "A system error occurred: #{message}"
  end

  def report_user_error(message)
    # All errors are also notices.
    report_user_notice(message)

    if not flash[:error] then
      flash[:error] = []
    end
    flash[:error] << message
  end
  
  def report_user_notice(message)
    if flash[:notice] then
      flash[:notice] = flash[:notice] + " " + message
    else
      flash[:notice] = message
    end
  end

  def bounce(notice)
    respond_to do |format|
      format.html { redirect_to :back, notice: notice }
    end
  end

  def bucket(items, &index_fn)
    result = {}
    items.each do |item|
      key = yield(item) # index_fn(item)
      result[key] = [] unless result.include? key
      result[key] << item
    end

    return result
  end

  # PayPal
  def redirect_to_paypal_express(items, callback_url, cancel_url)
    # We have to clean the flash when directing to another site, or its values will still be there when we redirect back.
    flash[:notice] = ""
    flash[:error] = []

    # It would be ideal to add items into the callback URL here, but we don't have an easy way to do that cleanly right now. The caller has to put them in callback_url manually if it wants them kept.

    # PayPal doesn't appear to allow mixed-currency payments. We hope there is only a single total!
    if items_have_multiple_currencies(items)
      return bounce('PayPal only supports a single currency per transaction! Items priced in different currencies cannot be purchased together.')
    end
    totals = paypal_item_totals(items)
    currency = totals.keys[0]
    price = totals[currency]
    
    puts "Sending to PayPal: (#{price} #{currency})"
    puts "#{items}"
    puts "Callback: #{callback_url}"
    puts "Cancel: #{cancel_url}"
    response = EXPRESS_GATEWAY.setup_purchase(price.to_i,
                                              :ip                => request.remote_ip,
                                              :return_url        => callback_url,
                                              :cancel_return_url => cancel_url,
                                              :items             => items,
                                              :currency          => currency,
                                              :allow_guest_checkout => true
    )
    if response.success? then
      redirect_to EXPRESS_GATEWAY.redirect_url_for(response.token)
    else
      puts "PAYPAL ERROR: #{response.message}"
      puts "PAYPAL RESPONSE: #{response.to_yaml}"
      bounce("There was an error from PayPal: #{response.message}")
    end
  end

  def paypal_item_totals(items)
    result = {}

    items.each do |item|
      currency = item[:currency]
      result[currency] = 0 unless result.include? currency
      result[currency] = result[currency] + (item[:quantity] * item[:amount])
    end
    
    return result
  end

  def items_have_multiple_currencies(items)
    paypal_item_totals(items).length > 1
  end
  
  def add_paypal_processing_fee(items)
    paypal_item_totals(items).each do |currency, total|
      items << { name: "PayPal Processing Fee", description: "2.9% of the total, plus 30 cents",
        quantity: 1, amount: paypal_processing_fee(total), currency: currency }
    end

    items
  end

  def paypal_processing_fee(total)
      # The fee is 2.9% of the total, plus 30 cents.
      # The totals are in cents already.
      ((total * 0.029) + 30).to_i
  end

  # Pays the specified address, and records it in the database as appropriate.  
  def paypal_pay(other_account, amount, currency, subject, note)
    puts "paypal_pay request: #{other_account}, #{amount}, #{subject}, #{note}"
    unfinished_transaction = PaypalTransaction.create!({ from: OUR_PAYPAL_ACCOUNT, to: other_account, amount: amount })
    response = EXPRESS_GATEWAY.transfer (amount * 100), other_account, subject: subject, note: note, currency: currency
    unfinished_transaction.response = response.to_yaml
    if response.success? then
      # We don't get back a transaction ID in the response for mass payments.
      # unfinished_transaction.paypal_transaction_id = response.paypal_transaction_id
      unfinished_transaction.save!
    else
      unfinished_transaction.destroy
    end

    puts "paypal_pay response: #{response.to_yaml}"

    # Returns a hash including the response and the transaction.
    { response: response, transaction: unfinished_transaction }
  end

  private

  def resolve_layout
    case action_name
    when "widget_tickets", "widget_users"
      "widget_tickets"
    when "show"
      "event_page"
    else
      "application"
    end
  end

  def stash_params
    cached_param_key = params[:post_param_cache_key]
    if cached_param_key and cached_param_key != "" then
        Rails.cache.write(cached_param_key, params)
    end
  end

  def stash_referrer
    cached_aff = params[:aff]
    if cached_aff and cached_aff != "" then
      if current_user
        current_user.referred_by = cached_aff
        current_user.save
      else
        Rails.cache.write('cached_referrer', cached_aff)
      end
    end
    
  end

  def require_user
    unless authenticated?
      session[:redirect_to] = request.url
      #redirect_to new_session_path if mobile?
      redirect_to new_user_path if mobile?
      redirect_to new_user_path unless mobile?
      return false
    end
    return true
  end

  def require_no_user
    if current_user
      redirect_to root_path, alert: "You are already logged in!"
      return false
    end
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_session && current_session.user
  end

  def current_session
    return @current_session if defined?(@current_session)
    @current_session

    if params and params[:perishable_token] and params[:perishable_token] != "" then
      puts "Trying to load via perishable token #{params[:perishable_token]}"
      user = User.find_by_perishable_token(params[:perishable_token])
      if user then
        @current_session = Session.create!(User.find_by_id(user.id))
        puts "Loaded a user via perishable token #{params[:perishable_token]}"
      end
    else
      # Log in by ID.
      @current_session = Session.find
    end

    return @current_session
  end

  def user
    current_user
  end

  def authenticated?
    current_user
  end

  def mobilize
    #request.format = :mobile if mobile?
  end

  def mobile?
    if request.format == :json
      return false
    elsif request.env['HTTP_USER_AGENT'] =~ /iPad/
      return false
    elsif request.env['HTTP_USER_AGENT'] =~ /playbook/
      return false
    else
      request.env['HTTP_USER_AGENT'] =~ /Mobile/
    end
  end

end
