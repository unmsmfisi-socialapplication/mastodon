Fabricator(:appeal_note) do
  appeal { Fabricate.build(:appeal) }
  account { Fabricate.build(:account) }
  content { Faker::Lorem.sentences }
end
