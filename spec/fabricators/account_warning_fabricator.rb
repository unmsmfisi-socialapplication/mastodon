# frozen_string_literal: true

Fabricator(:account_warning) do
  created_at { Time.current }
  account { Fabricate.build(:account) }
  target_account(fabricator: :account)
  text { Faker::Lorem.paragraph }
  action 'suspend'
end
