class Admin::BaseController < ApplicationController
  before_action :require_active_account
  before_action :set_paper_trail_whodunnit

  rescue_from Pundit::NotAuthorizedError, with: :refuse

  # Makes a missing authorize call fail a spec while every account is an admin.
  after_action :verify_authorized

  private

    # paper_trail looks for current_user, which this app doesn't have.
    def user_for_paper_trail
      Current.user&.id
    end

    # Without the redirect the action runs on and the suspension misses a write.
    def require_active_account
      return if Current.user&.active?

      terminate_session
      redirect_to new_session_path, alert: "That account is suspended."
    end

    def refuse
      redirect_to admin_root_path, alert: "You can't do that."
    end
end
