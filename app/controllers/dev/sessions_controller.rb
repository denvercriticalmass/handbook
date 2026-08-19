# Development only. The route is declared inside a Rails.env.development? guard,
# so this controller is unreachable anywhere else, and the check below means it
# stays unreachable if that guard is ever loosened.
class Dev::SessionsController < ApplicationController
  allow_unauthenticated_access

  before_action :only_in_development

  def create
    superadmin = User.find_by(role: :superadmin)

    if superadmin
      start_new_session_for superadmin
      redirect_to admin_root_path
    else
      redirect_to new_session_path, alert: "No superadmin yet. Run bin/rails db:seed."
    end
  end

  private

    def only_in_development
      head :not_found unless Rails.env.development?
    end
end
