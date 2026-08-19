# Admins can grow the admin pool but can't push each other around. Only the
# superadmin has teeth, and not against another superadmin.
class UserPolicy < ApplicationPolicy
  def index?
    user&.superadmin?
  end

  def manage?
    user&.superadmin? && !record.superadmin?
  end

  alias_method :update?, :manage?
  alias_method :destroy?, :manage?
end
