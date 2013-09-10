class Notifier < ActionMailer::Base
  default from: "Eventastic <support@eventastic.com>"


  def deliver_invitation_message_email(invitation, message, to)
    invitation_message_email(invitation, message, to).deliver
  end

  def invitation_message_email(invitation, message, to)
    @invitation = invitation
    @message = message
    @title = "You've received an invitation to an event!"
    @title = "You've received an invitation to an event!"
    @title_text = "You've received an invitation to an event!"
    @body_text =""
    @to = to
    mail to: to.email, subject: "You've received an invitation to an event!", template_name: "invitation_message"
  end

  def deliver_thank_you_email(thanks)
    thank_you_email(thanks).deliver
  end

  def thank_you_email(thanks)
    @thanks = thanks
    @title = "You've received a Thank You message!"
    @title_text = "You've received a Thank You message!"
    @body_text =""
    mail to: @thanks.to_email, subject: "You've received a Thank You message!", template_name: "thank_you_email"
  end

  def deliver_ticket_purchase_email(tickets)
    if tickets.length > 0 then
      ticket_purchase_email(tickets).deliver
    end
  end

  def ticket_purchase_email(tickets)
    # We discussed whether to send one email per ticket, or one containing all the tickets, and decided to send one email containing all of the tickets.
    # We pull the user information from the first ticket.
    # The template_name is explicitly specified, but it is ostensibly the same as the default.
    # This is because it doesn't work if we leave it at the default, so probably the default isn't actually what we think it is.
    @base_ticket = tickets[0]
    @tickets = tickets
    @title = "Your tickets for #{@base_ticket.event_name} are ready!"
    @title_text = "Your tickets are ready!"
    @body_text =""

    type = TicketType.find(@base_ticket.ticket_type_id)
    @event = Event.find(type.event_id)

    result = mail to: @base_ticket.guest_email, subject: "Your tickets for #{@base_ticket.event_name} are ready!", :template_name => 'ticket_purchase_email'


    #doc_html = render_to_string(:partial => "/ticket_instances/show.html.erb", :locals=>{:base_ticket => @base_ticket, :tickets => @tickets}, layout: false)
    #kit = PDFKit.new(doc_html)
    #pdf = kit.to_pdf

    result.attachments["tickets.pdf"] = generate_barcodes_pdf
    #result.attachments["tickets.pdf"] = pdf
    return result
  end

  def generate_barcodes_pdf()
    doc_html = render_to_string(template: "ticket_instances/show.pdf.erb", layout: false)
    doc_pdf = WickedPdf.new.pdf_from_string(doc_html, :page_size => 'Letter')
    return doc_pdf
  end

  def deliver_password_reset_instructions(user)
    password_reset_instructions(user).deliver
  end

  def password_reset_instructions(user)
    @user = user
    @title = "Password Reset Instructions"
    @title_text = "Password Reset Instructions"
    @body_text =""
    mail to: "#{user.email}", subject: "Password Reset Instructions"
  end
  
  def greet(user)
    @user = user
    @title = "Greetings From Eventastic"
    @title_text = "Welcome Aboard!"
    mail to: "#{user.display_name} <#{user.email}>", subject: "Greetings From Eventastic"
  end

  def close(user)
    @user = user
    @title = "Eventastic Account Closed"
    @title_text = "Parting Is Such Sweet Sorrow!"
    mail to: "#{user.display_name} <#{user.email}>", subject: "Goodbye From Eventastic"
  end

  def contact_us(user,email,phone,query)
    @user = user
    @phone = phone
    @email = email
    @query = query
    @title = "Eventastic Contact Us"
    @title_text = "Eventastic Contact Us"
    @body_text =""
    mail to: "support@eventastic.com", subject: "Eventastic Contact Us"
  end

  def alert_user(user,email,alert_title, alert)
    @user = user
    @email = email
    @title = alert_title
    @title_text = alert_title
    @alert_message = alert
    mail to: "support@eventastic.com", subject: "Eventastic: #{alert_title}"
  end

  def cashout_request(user,email,event)
    @user = user
    @email = email
    @event = event
    @title = "Customer Cashout Request!"
    @title_text = "Customer Cashout Request!"
    @body_text =""
    mail to: "support@eventastic.com", subject: "Customer Cashout Request!"
  end

  def cashout_request_processed(user,email,event, note)
    @user = user
    @email = email
    @event = event
    @note = note
    @title = "Customer Cashout Request!"
    @title_text = "Customer Cashout Request!"
    @body_text =""
    mail to: "support@eventastic.com", subject: "Customer Cashout Request!"
  end

  def cashout_request_client(user,email,event)
    @user = user
    @email = email
    @event = event
    @title = "Your Cashout Request Is In Review!"
    @title_text = "Your Cashout Request Is In Review!"
    @body_text =""
    mail to: "#{user.display_name} <#{user.email}>", subject: "Your Cashout Request Is In Review!"
  end

  def daily_metrics(name,email)
    @title = "Daily Metrics!"
    @title_text = "Daily Metrics!"
    @body_text =""
    mail to: "#{name} <#{email}>", subject: "Daily Metrics!"
  end

  def test_cashout(user, email, event)
    @user = user
    @email = email
    @event = event
    @title = "Test Cashout"
    @title_text = "Test Cashout"
    @body_text = ""
    mail to: "#{user.display_name} <#{user.email}>", subject: "Your Test Cashout Request"
  end

  def cg_cashout_request(user,email)
    @user = user
    @email = email
    @title = "Customer Cashout Request!"
    @title_text = "Customer Cashout Request!"
    @body_text =""
    mail to: "support@eventastic.com", subject: "Customer Cashout Request!"
  end

  def cg_cashout_request_client(user,email)
    @user = user
    @email = email
    @title = "Your Cashout Request Is In Review!"
    @title_text = "Your Cashout Request Is In Review!"
    @body_text =""
    mail to: "#{user.display_name} <#{user.email}>", subject: "Your Cashout Request Is In Review!"
  end

  def sales_person_invite(sales_person, owner_name, link)
    @owner_name = owner_name
    @sales_person = sales_person 
    @title = "You Have Been Invited To Be A Sales Person For " + owner_name
    @title_text = "You Have Been Invited To Be A Sales Person For " + owner_name
    @body_text =""
    @link = link
    mail to: "#{sales_person.display_name} <#{sales_person.email}>", subject: "You Have Been Invited To Be A Sales Person For " + owner_name
  end

  def sales_person_update(sales_person, link)
    @sales_person = sales_person 
    @email = @sales_person.email
    @title = "You Have A New URL To Log In"
    @title_text = "You Have A New URL To Log In"
    @body_text =""
    @link = link
    mail to: "#{sales_person.display_name} <#{sales_person.email}>", subject: "You Have A New URL To Log In"
  end

  def sales_person_resend(sales_person, link)
    @sales_person = sales_person 
    @email = @sales_person.email
    @title = "You Have Requested A Log In Link"
    @title_text = "You Have Requested A Log In Link"
    @body_text =""
    @link = link
    mail to: "#{sales_person.display_name} <#{sales_person.email}>", subject: "You Have Requested A Log In Link"
  end

  def notify_ticket_sale(owner, ticket, event)
    @owner = owner
    @ticket = ticket
    @ticket_type = TicketType.find(@ticket.ticket_type_id)
    @title = @ticket.guest_name + " has purchased a ticket"
    @title_text = @ticket.guest_name + " has purchased a ticket"
    @body_text =""
    mail to: "#{owner.display_name} <#{owner.email}>", subject: @ticket.guest_name + " has purchased a ticket"
  end

  def notify_cg_sale(owner, cash_gift)
    @owner = owner
    @cash_gift = cash_gift
    @cg_type = Cashgifttype.find(@cash_gift.cashgifttype_id)
    @title = @cash_gift.guest_name + " has made a cash donation to your cause"
    @title_text = @cash_gift.guest_name + " has made a cash donation to your cause"
    @body_text =""
    mail to: "#{owner.display_name} <#{owner.email}>", subject: @cash_gift.guest_name + " has made a cash donation to your cause"
  end

  def request_affiliate_approval(user)
    @user = user
    @title = "Affiliate Approval Request!"
    @title_text = "Affiliate Approval Request!"
    mail to: "support@eventastic.com", subject: "Affiliate Approval Request!"
  end
end
