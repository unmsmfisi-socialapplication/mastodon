# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountSuggestions do
  let(:account) { Fabricate(:account, username: 'alice') }
  let(:suggestion_service) { described_class.new(account) }

  describe 'Constants' do
    describe 'BATCH_SIZE' do
      it 'is set to 40' do
        expect(described_class::BATCH_SIZE).to eq(40)
      end
    end

    describe 'SOURCES' do
      it 'contains all required source providers' do
        expect(described_class::SOURCES).to eq([
          AccountSuggestions::SettingSource,
          AccountSuggestions::FriendsOfFriendsSource,
          AccountSuggestions::SimilarProfilesSource,
          AccountSuggestions::GlobalSource,
        ].freeze)
      end

      it 'is frozen to prevent modifications' do
        expect(described_class::SOURCES).to be_frozen
      end
    end
  end

  describe '#initialize' do
    it 'creates a new instance with an account' do
      expect(suggestion_service.instance_variable_get(:@account)).to eq(account)
    end
  end
end
