FactoryBot.define do
  factory :user do
    email_address { "user@example.com" }
    password { "password" }

    trait :superadmin do
      role { :superadmin }
    end

    trait :suspended do
      active { false }
    end
  end
end
