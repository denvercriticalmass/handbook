# Dev convenience only. Real content is written through the admin UI.
#
# The ride guidelines are a Guide record rather than homepage markup, per
# MVP_PLAN.md 1c, so they are editable and searchable like everything else.
author = User.first || User.create!(email_address: "joe@joesak.com", password: "bike lanes now", role: :superadmin)

Guide.find_or_create_by!(title: "Ride guidelines") do |guide|
  guide.created_by = author
  guide.body = <<~GUIDELINES
    Happy Friday!
    Yell happy friday to everyone you see and ring your bell. Make friends, bring good energy.

    Joy is paramount
    It's a protest, but don't be aggressive. We're not here to replace car dominance with bike dominance. We want to be a friendly spectacle for our neighbors.

    Share the streets
    Respect pedestrians, especially around crosswalks. Respect buses and transit riders too. Public transit and pedestrian dignity are part of the future we ride for.

    Respect your city
    When we stop to party, take your trash with you, don't tag anything, and don't break shit. We don't want that kind of reputation.

    Your experience matters
    We want the ride to feel safe enough that anyone can speak up if something feels off.

    Repair with kindness
    If someone raises an issue with you, hear them out and don't double down. Just repair it.
  GUIDELINES
end

puts "Seeded #{Guide.count} guide(s)."
