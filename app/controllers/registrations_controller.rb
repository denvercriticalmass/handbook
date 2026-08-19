class RegistrationsController < ApplicationController
  layout "admin"
  allow_unauthenticated_access

  def create
    if user = Registration.new(email_address: params[:email_address], password: params[:password]).create
      start_new_session_for user
      redirect_to root_path
    else
      redirect_to signin_path, alert: "That address can't register."
    end
  end
end
