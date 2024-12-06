# frozen_string_literal: true

class AppealNotePolicy < ApplicationPolicy
  def create?
    role.can?(:manage_appeals)
  end

  def destroy?
    owner?
  end

  private

  def owner?
    record.account_id == current_account&.id
  end
end
