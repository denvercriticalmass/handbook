# Asymmetric on purpose: the public side has no login, so reading is open to
# everyone and writing needs an account.
class CheatSheetPolicy < ApplicationPolicy
  def index?
    true
  end

  alias_method :show?, :index?

  def create?
    user&.admin? || user&.superadmin?
  end

  alias_method :new?, :create?
  alias_method :update?, :create?
  alias_method :edit?, :create?
  alias_method :history?, :create?
end
