FactoryBot.define do
  factory :waypoint do
    sequence(:name) { "Waypoint #{it}" }
    category { :crossing }
    latitude { 39.7364 }
    longitude { -104.9931 }
    note { "Wait for the light." }
    created_by factory: :user
  end
end
