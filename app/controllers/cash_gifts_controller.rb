require 'rubygems'
require 'active_merchant'

class CashGiftsController < ApplicationController
  before_filter :require_user, :only => [:index]
  CASHGIFT_STATUS_UNPAID = "unpaid"
  CASHGIFT_STATUS_PAID = "paid"
  CASHGIFT_STATUS_REFUNDED = "refunded"

  # GET /cash_gifts
  # GET /cash_gifts.json
  def index
    @cash_gifts = CashGift.find_all_by_id(current_user.id)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cash_gifts }
    end
  end

  # GET /cash_gifts/1
  # GET /cash_gifts/1.json
  def show
    @cash_gift = CashGift.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cash_gift }
    end
  end

  # GET /cash_gifts/new
  # GET /cash_gifts/new.json
  def new
    @cash_gift = CashGift.new

    if current_user then
      @cash_gift.guest_id = current_user.id
    end
    @cash_gift.guest_email = current_user ? current_user.email : ""
    @cash_gift.guest_name = current_user ? current_user.display_name : ""
    @cash_gift.status = CASHGIFT_STATUS_UNPAID
    @cash_gift.host_id = event.user_id

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @cash_gift }
    end
  end

  # GET /cash_gifts/1/edit
  def edit
    @cash_gift = CashGift.find(params[:id])
  end

  # POST /cash_gifts
  # POST /cash_gifts.json
  def create
    @cash_gift = CashGift.new(params[:cash_gift])
    @cash_gift.currency = Cashgifttype.find_by_id(@cash_gift.cashgifttype_id).currency
    if not @cash_gift.save
      puts @cash_gift.errors.to_yaml
      return bounce("The gift failed to save!")
    end

    if @cash_gift.amount == 0
      params[:id] = paypal_transaction_id
      gifts_paid
    else

      event = Event.where(:id => Cashgifttype.find_by_id(@cash_gift.cashgifttype_id).event_id).first


      cancel_url = root_url
      callback_url = url_for :controller => 'cash_gifts', :action => 'gifts_paid', :paid_gift_ids => [@cash_gift.id]
      # In the database, the ticket price is a BigNum, but we have to send a fixnum to PayPal.
      # PayPal wants an integer quantity of the smallest denomination. Here we're assuming that is cents.
      items = [{ name: @cash_gift.title, description: "Cash Gift/Donation for #{Event.find_by_id(Cashgifttype.find_by_id(@cash_gift.cashgifttype_id).event_id).name}",
                 quantity: 1, amount: (@cash_gift.amount * 100).to_i, currency: @cash_gift.currency }]
      if event.include_fees == true
      #items = add_paypal_processing_fee(items)
      end
      redirect_to_paypal_express(items, callback_url, cancel_url)
    end
  end

  def gifts_paid
    paypal_token = params[:token]
    paypal_details = EXPRESS_GATEWAY.details_for(paypal_token)

    paid_gift_id = params[:paid_gift_ids]
    paid_gift = CashGift.find_by_id(paid_gift_id)
    paid_gift.status = CASHGIFT_STATUS_PAID
    event = Event.find_by_id(Cashgifttype.find_by_id(paid_gift.cashgifttype_id))

    if event.include_fees == true
      paid_gift.fee_charged = true
    else
      paid_gift.fee_charged = false
    end

    amount_in_cents = (paid_gift.amount * 100)
    if event.include_fees == true
    #amount_in_cents += paypal_processing_fee(amount_in_cents)
    end

    purchase = EXPRESS_GATEWAY.purchase(amount_in_cents,
                                        :ip       => request.remote_ip,
                                        :payer_id => paypal_details.payer_id,
                                        :token    => paypal_token,
                                        :currency => paid_gift.currency
                                        )

    paypal_transaction_id = params[:token]

    if !purchase.success? and FALSE
      @message = purchase.message
      return bounce(@message)
    else
      paid_gift.paypal_transaction_id = paypal_transaction_id
      paid_gift.save!
    end

    owner = User.find(event.user_id)
    Notifier.notify_cg_sale(owner, paid_gift).deliver

    respond_to do |format|
      format.html { redirect_to "/events/#{Cashgifttype.find_by_id(paid_gift.cashgifttype_id).event_id}", notice: 'Your Payment Was Made Successfully!'}
    end
  end

  # PUT /cash_gifts/1
  # PUT /cash_gifts/1.json
  def update
    @cash_gift = CashGift.find(params[:id])

    respond_to do |format|
      if @cash_gift.update_attributes(params[:cash_gift])
        format.html { redirect_to @cash_gift, notice: 'Your Cash Gift Was Successfully Updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @cash_gift.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cash_gifts/1
  # DELETE /cash_gifts/1.json
  def destroy
    @cash_gift = CashGift.find(params[:id])
    @cash_gift.destroy

    respond_to do |format|
      format.html { redirect_to cash_gifts_url }
      format.json { head :no_content }
    end
  end

  def gifts_successfully_purchased
  end

  def gifts_error
  end

  def cashout
    @user = current_user

    unless params[:cg_key2] == @user.cg_key2
      return "Security answer is incorrect"
    end

    dev = FALSE
    if not dev then
      # Currently, we just send emails.
      Notifier.cg_cashout_request(@user,@user.email).deliver
      Notifier.cg_cashout_request_client(@user,@user.email).deliver
      respond_to do |format|
        format.html { redirect_to root_path, notice: "Your Cash-Out Request Has Been Successfully Processed, And Is In Review!" }
        format.json { head :no_content }
      end
    else
      # The cash-out includes all cash gifts that have been paid, that have not already been cashed out.
      gifts = @user.cash_gifts.where("(payout_user_transaction_id IS NULL) AND status = ?", CASHGIFT_STATUS_PAID)

      # Organize the gifts by currency.
      currency_gifts = bucket(gifts) do |gift|
        gift.currency
      end

      if currency_gifts.length == 0 then
        error_message = "There are no gifts for this event that have been paid for that have not already been cashed out."
      else
        currency_gifts.each do |currency, local_gifts|
          @affiliate = @user.referred_by
          local_error = cashout_gifts(local_gifts)
          if local_error and local_error != ""
            if error_message and error_message != ""
              error_message = error_message + "\n" + local_error
            else
              error_message = local_error
            end
          end
        end
      end
      
      if not error_message then
        respond_to do |format|
          format.html { redirect_to events_path, notice: "Your cash-out has been successfully processed!" }
          format.json { render json: 'success' }
        end
      else
        respond_to do |format|
          format.html { redirect_to events_path, alert: "There was an error processing your cash-out: #{error_message}" }
          format.json { render json: error_message }
        end
      end
    end
  end

  # References a few instance variables that must be defined by the caller.
  # We transfer the total amount, minus fees, to the user, and we transfer the fees to a separate account.
  def cashout_gifts(gifts)
    total_cashout_amount = gifts.map(&:amount).reduce(:+)
    total_fees = gifts.map(&:cashout_fee).reduce(:+).round(2)

    # Assumes at least one gift!
    currency = gifts[0].currency

    @event = Event.find(Cashgifttype.find(gifts[0].cashgifttype_id).event_id)

    affiliate_payout = 0
    if @event.referrer
      @affiliate = User.find(@event.referrer)
      affiliate_payout = (total_fees * (@affiliate.negotiated_commission_rate / 100)).round(2)
    end


    #affiliate_payout = [total_cashout_amount * 0.0125, max_affiliate_payout_for(@affiliate, @user)].min.round(2)
    
    # The affiliate payout comes out of the fees, rather than the gross.
    fees = (total_fees - affiliate_payout).round(2)

    user_payout = total_cashout_amount - (fees + affiliate_payout)
    
    transfer_subject = "Cash Gift Cash-out"
    transfer_note = "Cash-out Amount: #{total_cashout_amount} #{currency}"
    if user_payout > 0 then
      transfer_note = transfer_note + ", Paid Amount: #{user_payout} #{currency}" 
    end
    if total_fees > 0 then
      # The user note has affiliate and fees grouped together.
      user_transfer_note = transfer_note + ", Fees: #{total_fees} #{currency}"
    end
    if fees > 0 then
      transfer_note = transfer_note + ", Fees: #{fees} #{currency}"
    end
    if affiliate_payout > 0 then
      transfer_note = transfer_note + ", Affiliate Payout: #{affiliate_payout} #{currency}" 
    end

    puts "Paying out Cash Gift Cashout: fees: #{fees} user: #{user_payout} affiliate: #{affiliate_payout}"

    # Pay Fees (to ourselves)
    pay_result = paypal_pay(FEES_PAYPAL_ACCOUNT, fees, currency, transfer_subject, transfer_note)
    fee_response = pay_result[:response]
    fee_transaction = pay_result[:transaction]
    if not fee_response.success? then
      return fee_response.message
    end

    # This loops over the collection, saving each element, so it is not ideal.
    # A bulk update would use less database resources, but this method has easier maintenance.
    gifts.each do |gift|
      gift.payout_fee_transaction_id = fee_transaction.id
      gift.save!
    end
    
    # Pay User
    pay_result = paypal_pay(@user.email, user_payout, currency, transfer_subject, user_transfer_note)
    user_response = pay_result[:response]
    user_transaction = pay_result[:transaction]
    
    if not user_response.success? then
      return user_response.message
    end

    # This loops over the collection, saving each element, so it is not ideal.
    # A bulk update would use less database resources, but this method has easier maintenance.
    gifts.each do |gift|
      gift.payout_user_transaction_id = user_transaction.id
      gift.save!
    end
    
    # Pay Affiliate
    if affiliate_payout > 0 then
      pay_result = paypal_pay(@affiliate.email, affiliate_payout, currency, transfer_subject, transfer_note)
      affiliate_response = pay_result[:response]
      affiliate_transaction = pay_result[:transaction]
      
      if not affiliate_response.success? then
        return affiliate_response.message
      end

      # This loops over the collection, saving each element, so it is not ideal.
      # A bulk update would use less database resources, but this method has easier maintenance.
      #gifts.each do |gift|
      #  gift.payout_affiliate_transaction_id = affiliate_transaction.id
      #  gift.save!
      #end
    end

    return nil
  end
end
