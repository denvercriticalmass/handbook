FactoryBot.define do
  factory :invitation do
    email_address { "corker@example.com" }
    invited_by factory: :user

    trait :accepted do
      accepted_at { Time.current }
    end

    trait :expired do
      expires_at { 1.day.ago }
    end
  end
end
