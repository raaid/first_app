class InvitedToController < ApplicationController

  before_filter :mobilize
  respond_to :html, :js, :mobile, :json

  def show
    if numeric?(params[:id])
      @invitations = ActiveRecord::Base.connection.select_all("SELECT name, email, status, description FROM invitations LEFT JOIN contact_list_members ON invitations.id = contact_list_members.contact_list_id LEFT JOIN invitation_responses ON invitations.id = invitation_responses.id")
# WHERE Invitations.invited_to_id = #{params[:id]}"
    end
  end
end
