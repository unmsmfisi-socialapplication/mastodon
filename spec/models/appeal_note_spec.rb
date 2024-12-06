# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AppealNote do
  describe 'Scopes' do
    describe '.chronological' do
      it 'returns appeal notes oldest to newest' do
        appeal = Fabricate(:appeal)
        note1 = Fabricate(:appeal_note, appeal: appeal)
        note2 = Fabricate(:appeal_note, appeal: appeal)

        expect(appeal.notes.chronological).to eq [note1, note2]
      end
    end
  end

  describe 'Validations' do
    subject { Fabricate.build :appeal_note }

    describe 'content' do
      it { is_expected.to_not allow_value('').for(:content) }
      it { is_expected.to validate_length_of(:content).is_at_most(described_class::CONTENT_SIZE_LIMIT) }
    end
  end
end
