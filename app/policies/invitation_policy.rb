# Names both roles rather than checking for an account, so a future non-admin
# role doesn't inherit the right.
class InvitationPolicy < ApplicationPolicy
  def create?
    user&.admin? || user&.superadmin?
  end

  alias_method :new?, :create?
end
