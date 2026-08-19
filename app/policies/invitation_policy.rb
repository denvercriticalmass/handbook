# Any admin may invite another admin. Stated as both roles rather than "has an
# account", so a future non-admin role doesn't silently inherit the right.
class InvitationPolicy < ApplicationPolicy
  def create?
    user&.admin? || user&.superadmin?
  end

  alias_method :new?, :create?
end
