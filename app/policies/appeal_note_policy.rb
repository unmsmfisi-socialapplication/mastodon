# frozen_string_literal: true

class AppealNotePolicy < ApplicationPolicy
  def create?
    role.can?(:manage_appeals)
  end

  def destroy?
    owner? || (role.can?(:manage_appeals) && role.overrides?(record.account.user_role))
  end

  private

  def owner?
    record.account_id == current_account&.id
  end
end
