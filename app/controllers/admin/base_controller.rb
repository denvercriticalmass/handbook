# Authentication is inherited. The active check is belt and braces: suspension
# already destroys open sessions, so a suspended admin normally has no session
# to resume.
class Admin::BaseController < ApplicationController
  before_action :require_active_account
  before_action :set_paper_trail_whodunnit

  rescue_from Pundit::NotAuthorizedError, with: :refuse

  # Turns "we remembered to call authorize" into something a spec can fail on.
  # Without it, dropping an authorize call is invisible while every account
  # happens to be an admin.
  after_action :verify_authorized

  private

    # paper_trail looks for current_user, which this app doesn't have.
    def user_for_paper_trail
      Current.user&.id
    end

    def require_active_account
      terminate_session unless Current.user&.active?
    end

    def refuse
      redirect_to root_path, alert: "You can't do that."
    end
end
