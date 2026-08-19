FactoryBot.define do
  factory :cheat_sheet do
    sequence(:title) { "Cheat sheet #{it}" }
    body { "Channel 1 is the front of the ride." }
    created_by factory: :user
  end
end
