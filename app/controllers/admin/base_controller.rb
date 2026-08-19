# Authentication is inherited. The active check is belt and braces: suspension
# already destroys open sessions, so a suspended admin normally has no session
# to resume.
class Admin::BaseController < ApplicationController
  layout "admin"

  before_action :require_active_account

  rescue_from Pundit::NotAuthorizedError, with: :refuse

  private

    def require_active_account
      terminate_session unless Current.user&.active?
    end

    def refuse
      redirect_to root_path, alert: "You can't do that."
    end
end
