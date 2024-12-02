# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AppealNotePolicy  do
  subject { described_class }

  let(:admin)   { Fabricate(:user, role: UserRole.find_by(name: 'Admin')).account }
  let(:admin2)   { Fabricate(:user, role: UserRole.find_by(name: 'Admin')).account }

  let(:john)    { Fabricate(:account) }

  permissions :create? do
    context 'when staff?' do
      it 'permits' do
        expect(subject).to permit(admin, AppealNote)
      end
    end

    context 'with !staff?' do
      it 'denies' do
        expect(subject).to_not permit(john, AppealNote)
      end
    end
  end

  permissions :destroy? do
    context 'when owner?' do
      it 'permit' do
        appeal = Fabricate(:appeal)
        appeal_note = Fabricate(:appeal_note, appeal: appeal, account: admin)
        expect(subject).to permit(admin, appeal_note)
      end
    end

    context 'with !owner?' do
      it 'denies' do
        appeal = Fabricate(:appeal)
        appeal_note = Fabricate(:appeal_note, appeal: appeal, account: admin)
        expect(subject).to_not permit(admin2, appeal_note)
      end
    end
  end
end
