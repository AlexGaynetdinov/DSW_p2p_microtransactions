class UserPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin? || record == user
  end

  # Create is done separately on sign up

  def update?
    user == record
  end

  def destroy?
    user.admin?
  end
end