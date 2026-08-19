class InvitationPolicy < ApplicationPolicy
  def create?
    user&.admin? || user&.superadmin?
  end

  alias_method :new?, :create?
end
