class CommentsController < ApplicationController

  #before_filter :require_user
  before_filter :mobilize
  respond_to :html, :js, :mobile, :json

  # GET /comments/1
  # GET /comments/1.json
  def show
    @comment = Comment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @comment }
    end
  end

  # GET /comments/new
  # GET /comments/new.json
  def new
    @comment = Comment.new()

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @comment }
    end
  end

  # GET /comments/1/edit
  def edit
    @comment = Comment.find(params[:id])
  end

  # POST /comments
  # POST /comments.json
  def create

    @comment = Comment.new()
    @comment.name = params[:name]
    @comment.email = params[:email]
    @comment.message = params[:msg]
    @comment.user = params[:uid]
    @comment.event_id = params[:id]
    @event = Event.find_by_id(@comment.event_id)
    respond_with do |format|
      if @comment.save
        @comment["time"] = @comment.created_at.strftime("%Y-%m-%d %-I:%M %P")
        format.js {respond_with :json => @comment }
        format.html {render :json => @comment }
        #format.html { redirect_to @event, notice: 'Your Comment Was Successfully Posted.' }
        format.json { render json: @comment, status: :created, location: @comment }
        format.mobile { render json: @comment, status: :created, location: @comment }
      else
        format.html { render action: "new" }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /comments/1
  # PUT /comments/1.json
  def update
    @comment = Comment.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        format.html { redirect_to posts_url, notice: 'Your Comment Was Successfully Updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @comment = Comment.find(params[:id])
    @post = @comment.post
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to posts_url }
      format.js { respond_with(@comment)}
      format.json { head :no_content }
    end
  end
end