# Authentication is inherited. The active check is belt and braces: suspension
# already destroys open sessions, so a suspended admin normally has no session
# to resume. It only bites when a row was changed without the callback running.
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

    # terminate_session doesn't halt the request, so without this redirect the
    # action still runs and a suspended admin gets one more write in.
    def require_active_account
      return if Current.user&.active?

      terminate_session
      redirect_to new_session_path, alert: "That account is suspended."
    end

    def refuse
      redirect_to root_path, alert: "You can't do that."
    end
end
