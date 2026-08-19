class InvitationPolicy < ApplicationPolicy
  def create?
    user&.admin? || user&.superadmin?
  end

  alias_method :new?, :create?
  alias_method :index?, :create?
  alias_method :destroy?, :create?
  alias_method :resend?, :create?
end
