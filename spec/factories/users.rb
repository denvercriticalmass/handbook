FactoryBot.define do
  factory :user do
    sequence(:name) { "Corker #{it}" }
    sequence(:email_address) { "user#{it}@example.com" }
    password { "password" }

    trait :superadmin do
      role { :superadmin }
    end

    trait :suspended do
      active { false }
    end
  end
end
