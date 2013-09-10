class PaypalTransactionsController < ApplicationController

  before_filter :mobilize
  respond_to :html, :js, :mobile, :json

  def index
    @paypal_transactions = PaypalTransaction.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @paypal_transactions }
    end
  end

  # GET /paypal_transactions/1
  # GET /paypal_transactions/1.json
  def show
    @paypal_transaction = PaypalTransaction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @paypal_transaction }
    end
  end

  # GET /paypal_transactions/new
  # GET /paypal_transactions/new.json
  def new
    @paypal_transaction = PaypalTransaction.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @paypal_transaction }
    end
  end

  # GET /paypal_transactions/1/edit
  def edit
    @paypal_transaction = PaypalTransaction.find(params[:id])
  end

  # POST /paypal_transactions
  # POST /paypal_transactions.json
  def create
    @paypal_transaction = PaypalTransaction.new(params[:paypal_transaction])

    respond_to do |format|
      if @paypal_transaction.save
        format.html { redirect_to @paypal_transaction, notice: 'Your Paypal Transaction Was Successfully Created.' }
        format.json { render json: @paypal_transaction, status: :created, location: @paypal_transaction }
      else
        format.html { render action: "new" }
        format.json { render json: @paypal_transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /paypal_transactions/1
  # PUT /paypal_transactions/1.json
  def update
    @paypal_transaction = PaypalTransaction.find(params[:id])

    respond_to do |format|
      if @paypal_transaction.update_attributes(params[:paypal_transaction])
        format.html { redirect_to @paypal_transaction, notice: 'Your Paypal Transaction Was Successfully Updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @paypal_transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /paypal_transactions/1
  # DELETE /paypal_transactions/1.json
  def destroy
    @paypal_transaction = PaypalTransaction.find(params[:id])
    @paypal_transaction.destroy

    respond_to do |format|
      format.html { redirect_to paypal_transactions_url }
      format.json { head :no_content }
    end
  end
end
