FactoryBot.define do
  factory :passkey do
    user
    sequence(:external_id) { "credential-#{it}" }
    sequence(:nickname) { "Phone #{it}" }
    public_key { "a public key" }
  end
end
