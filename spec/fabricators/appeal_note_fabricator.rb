Fabricator(:appeal_note) do
  appeal { Fabricate.create(:appeal) }
  account { Fabricate.build(:account) }
  content { Faker::Lorem.sentences }
end
