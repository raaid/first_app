class ContactListMembersController < ApplicationController

  before_filter :mobilize
  respond_to :html, :js, :mobile, :json

  def create
    if params[:contact_list_members]
      contact_list_members = params[:contact_list_members]
    else
      contact_list_members = {"0" => params[:contact_list_member]}
    end


    puts contact_list_members.to_yaml
    success = true
    contact_list_members.each do |index, contact_list_member|
      puts contact_list_member.to_yaml
      if success and not ContactListMember.exists?(email: contact_list_member[:email], contact_list_id: contact_list_member[:contact_list_id])
        @contact_list_member = ContactListMember.new(contact_list_member)
        if not @contact_list_member.save
          success = false
        end
      end
    end  

    respond_to do |format|
      if success
        format.html { head :no_content }
        format.json { render json: @contact_list_member, status: :created, location: @contact_list_member }
      else
        format.html { head :no_content }
        format.json { render json: @contact_list_member.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @contact_list_member = ContactListMember.find(params[:id])

    respond_to do |format|
      if @contact_list_member.update_attributes(params[:contact_list_member])
        # Make sure we return SOMETHING for JSON, else Firefox gives a warning in the script log.
        format.html { head :no_content }
        format.json { render json: true }
      else
        format.html { render action: "edit" }
        format.json { render json: @contact_list_member.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @contact_list_member = ContactListMember.find(params[:id])
    @contact_list_member.destroy

    # Make sure we return SOMETHING for JSON, else Firefox gives a warning in the script log.
    respond_to do |format|
      format.html { head :no_content }
      format.json { render json: true }
    end
  end
end
