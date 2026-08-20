class OmniauthSessionsController < ApplicationController
  allow_unauthenticated_access

  def create
    if user = admin_behind(request.env["omniauth.auth"])
      start_new_session_for user
      redirect_to after_authentication_url
    else
      refuse
    end
  end

  def failure
    refuse
  end

  private

    def admin_behind(auth)
      User.active.find_by(email_address: auth&.info&.email.to_s.strip.downcase)
    end

    # Says nothing about whether the account exists or is only suspended.
    def refuse
      redirect_to new_session_path, alert: "That Google account can't sign in here."
    end
end
