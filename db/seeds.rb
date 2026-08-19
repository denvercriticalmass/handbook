# Dev convenience only. Real content is written through the admin UI.
#
# The ride guidelines are a Guide record rather than homepage markup, so they
# stay editable and searchable like everything else.
author = User.first || User.create!(
  name: "Joe",
  email_address: "joe@joesak.com",
  password: "bike lanes now",
  role: :superadmin
)

Guide.find_or_create_by!(title: "Ride guidelines") do |guide|
  guide.created_by = author
  guide.body = <<~HTML
    <h1>Happy Friday!</h1>
    <div>Yell happy friday to everyone you see and ring your bell. Make friends, bring good energy.</div>
    <h1>Joy is paramount</h1>
    <div>It's a protest, but don't be aggressive. We're not here to replace car dominance with bike dominance. We want to be a friendly spectacle for our neighbors.</div>
    <h1>Share the streets</h1>
    <div>Respect pedestrians, especially around crosswalks. Respect buses and transit riders too. Public transit and pedestrian dignity are part of the future we ride for.</div>
    <h1>Respect your city</h1>
    <div>When we stop to party, take your trash with you, don't tag anything, and don't break shit. We don't want that kind of reputation.</div>
    <h1>Your experience matters</h1>
    <div>We want the ride to feel safe enough that anyone can speak up if something feels off.</div>
    <h1>Repair with kindness</h1>
    <div>If someone raises an issue with you, hear them out and don't double down. Just repair it.</div>
  HTML
end

puts "Seeded #{Guide.count} guide(s)."
