class UserPolicy < ApplicationPolicy
  # Any admin can read the roster and invite from it. Only the superadmin can
  # act on anyone, which is #manage?.
  def index?
    user&.admin? || user&.superadmin?
  end

  def manage?
    user&.superadmin? && !record.superadmin?
  end

  alias_method :update?, :manage?
  alias_method :destroy?, :manage?
end
