class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def create
    registration = Registration.new(
      email_address: params[:email_address],
      password: params[:password],
      name: params[:name],
      token: params[:token]
    )

    if user = registration.create
      start_new_session_for user
      redirect_to admin_root_path
    else
      redirect_to signin_path, alert: "That address can't register."
    end
  end
end
