FactoryBot.define do
  factory :guide do
    sequence(:title) { "Guide #{it}" }
    body { "How this works." }
    created_by factory: :user
  end
end
