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

  describe '#remove' do
    let(:target_account_id) { 123 }

    it 'creates a FollowRecommendationMute record for the specified account' do
      mute = instance_spy(FollowRecommendationMute)
      allow(FollowRecommendationMute).to receive(:create).and_return(mute)

      suggestion_service.remove(target_account_id)

      expect(FollowRecommendationMute).to have_received(:create).with(
        account_id: account.id,
        target_account_id: target_account_id
      )
    end
  end

  describe '#get' do
    let(:limit) { 10 }
    let(:offset) { 0 }
    let(:mock_suggestions) do
      [
        [1, ['friends_of_friends']],
        [2, ['similar_profiles']],
        [3, ['global']],
      ]
    end

    let(:suggested_user_one) { Fabricate(:account, id: 1, username: 'user1') }
    let(:suggested_user_two) { Fabricate(:account, id: 2, username: 'user2') }
    let(:suggested_user_three) { Fabricate(:account, id: 3, username: 'user3') }
    let(:suggested_accounts) { [suggested_user_one, suggested_user_two, suggested_user_three] }

    before do
      allow(Rails.cache).to receive(:fetch).and_return(mock_suggestions)
      relation_double = instance_double(ActiveRecord::Relation, includes: suggested_accounts)
      allow(Account).to receive(:where).and_return(relation_double)
      allow(suggested_accounts).to receive(:index_by).and_return(suggested_accounts.index_by(&:id))
    end

    context 'when fetching basic suggestions' do
      it 'returns the correct number of suggestions' do
        results = suggestion_service.get(limit)
        expect(results.length).to eq(3)
      end

      it 'returns suggestion objects with the expected structure' do
        results = suggestion_service.get(limit)
        expect(results).to all(be_a(AccountSuggestions::Suggestion))
      end
    end

    context 'when applying pagination parameters' do
      it 'respects the limit parameter' do
        results = suggestion_service.get(2)
        expect(results.length).to eq(2)
      end

      it 'respects the offset parameter' do
        results = suggestion_service.get(limit, 1)
        expect(results.length).to eq(2)
      end
    end

    context 'when handling cache behavior' do
      it 'caches the results with appropriate expiration' do
        suggestion_service.get(limit)
        expect(Rails.cache).to have_received(:fetch)
          .with("follow_recommendations/#{account.id}", expires_in: 15.minutes)
      end
    end

    context 'when handling missing accounts' do
      let(:mock_suggestions) do
        [
          [1, ['friends_of_friends']],
          [999, ['similar_profiles']], # Non-existent account
          [3, ['global']],
        ]
      end

      it 'filters out non-existent accounts gracefully' do
        results = suggestion_service.get(limit)
        expect(results.length).to eq(2)
        expect(results.map { |r| r.account.id }).to_not include(999)
      end
    end

    context 'when handling BATCH_SIZE limits' do
      let(:base_id) { 1000 }

      it 'respects the BATCH_SIZE constant when gathering suggestions' do
        allow(Rails.cache).to receive(:fetch).and_yield
        sources_double = instance_double(AccountSuggestions::GlobalSource)

        accounts = (base_id...(base_id + 50)).map do |i|
          Fabricate(:account, username: "user#{i}")
        end

        allow(sources_double).to receive(:get).and_return(
          accounts.map { |acc| [acc.id, ['global']] }
        )
        allow(AccountSuggestions::GlobalSource).to receive(:new).and_return(sources_double)

        [AccountSuggestions::SettingSource,
         AccountSuggestions::FriendsOfFriendsSource,
         AccountSuggestions::SimilarProfilesSource].each do |source|
          allow(source).to receive(:new)
            .and_return(instance_double(source, get: []))
        end

        results = suggestion_service.get(50)
        expect(results.length).to be <= described_class::BATCH_SIZE
      end
    end
  end

  describe 'source integration behavior' do
    context 'when regenerating cache from all available sources' do
      before do
        allow(Rails.cache).to receive(:fetch).and_yield

        allow(AccountSuggestions::SettingSource).to receive(:new)
          .and_return(instance_double(AccountSuggestions::SettingSource, get: [[1, [:setting]]]))
        allow(AccountSuggestions::FriendsOfFriendsSource).to receive(:new)
          .and_return(instance_double(AccountSuggestions::FriendsOfFriendsSource, get: [[2, [:friends_of_friends]]]))
        allow(AccountSuggestions::SimilarProfilesSource).to receive(:new)
          .and_return(instance_double(AccountSuggestions::SimilarProfilesSource, get: [[3, [:similar_profiles]]]))
        allow(AccountSuggestions::GlobalSource).to receive(:new)
          .and_return(instance_double(AccountSuggestions::GlobalSource, get: [[4, [:global]]]))

        [1, 2, 3, 4].each { |id| Fabricate(:account, id: id) }
      end

      it 'combines and aggregates results from all sources correctly' do
        results = suggestion_service.get(4)

        expect(results.map { |r| r.account.id }).to contain_exactly(1, 2, 3, 4)

        sources = results.map(&:sources)
        expect(sources).to include(
          [:setting],
          [:friends_of_friends],
          [:similar_profiles],
          [:global]
        )
      end

      it 'aggregates sources when the same account is suggested multiple times' do
        suggested_account = Fabricate(:account)

        allow(AccountSuggestions::SettingSource).to receive(:new)
          .and_return(instance_double(AccountSuggestions::SettingSource,
            get: [[suggested_account.id, [:setting]]]))
        allow(AccountSuggestions::GlobalSource).to receive(:new)
          .and_return(instance_double(AccountSuggestions::GlobalSource,
            get: [[suggested_account.id, [:global]]]))

        allow(AccountSuggestions::FriendsOfFriendsSource).to receive(:new)
          .and_return(instance_double(AccountSuggestions::FriendsOfFriendsSource, get: []))
        allow(AccountSuggestions::SimilarProfilesSource).to receive(:new)
          .and_return(instance_double(AccountSuggestions::SimilarProfilesSource, get: []))

        results = suggestion_service.get(1)
        suggestion = results.first

        expect(suggestion.sources).to contain_exactly(:setting, :global)
        expect(results.length).to eq(1)
      end

      it 'handles malformed source responses gracefully' do
        test_account_1 = Fabricate(:account, username: 'malformed_test_1')
        test_account_2 = Fabricate(:account, username: 'malformed_test_2')
        test_account_3 = Fabricate(:account, username: 'malformed_test_3')
        test_account_4 = Fabricate(:account, username: 'malformed_test_4')

        allow(Rails.cache).to receive(:fetch).and_yield

        allow(AccountSuggestions::SettingSource).to receive(:new)
          .and_return(instance_double(AccountSuggestions::SettingSource,
            get: [
              [test_account_1.id, nil],
              [test_account_2.id, []],
              [test_account_3.id, 'invalid'],
              [test_account_4.id, [:valid]]
            ]))

        [AccountSuggestions::FriendsOfFriendsSource,
         AccountSuggestions::SimilarProfilesSource,
         AccountSuggestions::GlobalSource].each do |source|
          allow(source).to receive(:new)
            .and_return(instance_double(source, get: []))
        end

        results = suggestion_service.get(4)

        expect(results).to all(be_a(AccountSuggestions::Suggestion))
        expect(results.map { |r| r.sources }).to all(be_an(Array))
        expect(results.map { |r| r.sources.flatten }).to all(all(be_a(Symbol)))

        result_ids = results.map { |r| r.account.id }
        expect(result_ids).to include(test_account_1.id, test_account_2.id,
                                    test_account_3.id, test_account_4.id)
      end
    end
  end
end
