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
