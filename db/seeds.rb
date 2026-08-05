# Sample club data for local development so the stats/metrics pages have
# something to show. Idempotent: re-running updates nothing and creates no
# duplicates (records are looked up by natural keys). Uses @example.com members
# so it won't collide with real accounts.
#
#   bin/rails db:seed

puts "Seeding sample whiskey club data..."

PASSWORD = "password".freeze

# Each member has a rating "bias" that shapes the stats:
#   ben is harsh, cara is generous, ava rates closest to the group (golden nose).
members = {
  ava: { name: %w[Ava Accurate],  bias: 0.0 },
  ben: { name: %w[Ben Harsh],     bias: -2.0 },
  cara: { name: %w[Cara Generous], bias: 2.0 },
  dan: { name: %w[Dan Tastemaker], bias: 0.4 },
  eve: { name: %w[Eve Even], bias: 0.6 },
  finn: { name: %w[Finn Fickle], bias: -0.7 },
  gia: { name: %w[Gia Genial], bias: 0.9 },
  hugo: { name: %w[Hugo Hesitant], bias: -0.4 }
}

users = members.transform_values do |attrs|
  first, last = attrs[:name]
  User.find_or_create_by!(email: "#{first.downcase}@example.com") do |u|
    u.first_name = first
    u.last_name  = last
    u.password   = PASSWORD
  end
end
bias = members.transform_values { |attrs| attrs[:bias] }

# Past regular tastings: [days_ago, bringer, bottle name, distillery, quality].
# Dan brings two (so he qualifies as tastemaker); Lagavulin appears most
# (so it's the most-poured distillery).
tastings = [
  [70, :dan,  "16 Year",      "Lagavulin",   4.7],
  [56, :dan,  "Uigeadail",    "Ardbeg",      4.4],
  [42, :eve,  "12 Year",      "Lagavulin",   3.0],
  [35, :finn, "10 Year",      "Talisker",    3.6],
  [21, :gia,  "DoubleWood 12", "Balvenie",   3.9],
  [10, :hugo, "18 Year", "Glenfiddich", 3.3]
]

def score_for(quality, bias)
  (quality + bias).round.clamp(0, 5)
end

tastings.each do |days_ago, bringer_key, name, distillery, quality|
  meeting = Meeting.find_or_create_by!(date: Time.zone.today - days_ago) do |m|
    m.bottle_bringer = users[bringer_key]
    m.is_flight = false
    m.status = :completed
  end

  bottle = Bottle.find_or_create_by!(meeting: meeting, name: name) do |b|
    b.user = users[bringer_key]
    b.distillery = distillery
    b.age = name[/\d+/]&.to_i
    b.bottle_type = "Single Malt Scotch"
    b.revealed_at = meeting.date.to_time
  end

  users.each do |key, user|
    Rating.find_or_create_by!(user: user, bottle: bottle) do |r|
      r.score = score_for(quality, bias[key])
      r.comment = "Notes from #{user.first_name}."
    end
  end
end

# A past flight night: one meeting, three bottles from different members.
flight = Meeting.find_or_create_by!(date: Time.zone.today - 28) do |m|
  m.bottle_bringer = nil
  m.is_flight = true
  m.status = :completed
end

flight_bottles = [
  [:cara, "Peated Cask",   "Bunnahabhain", 4.2],
  [:finn, "Sherry Bomb",   "GlenDronach",  3.7],
  [:gia,  "Cask Strength", "Aberlour",     4.0]
]

flight_bottles.each do |bringer_key, name, distillery, quality|
  bottle = Bottle.find_or_create_by!(meeting: flight, name: name) do |b|
    b.user = users[bringer_key]
    b.distillery = distillery
    b.bottle_type = "Single Malt Scotch"
    b.revealed_at = flight.date.to_time
  end

  users.each do |key, user|
    Rating.find_or_create_by!(user: user, bottle: bottle) do |r|
      r.score = score_for(quality, bias[key])
    end
  end
end

# An upcoming tasting with an unrevealed bottle (so you can test reveal + rating).
upcoming = Meeting.find_or_create_by!(date: Time.zone.today + 7) do |m|
  m.bottle_bringer = users[:ava]
  m.is_flight = false
  m.status = :scheduled
end
Bottle.find_or_create_by!(meeting: upcoming, name: "Mystery Dram") do |b|
  b.user = users[:ava]
  b.distillery = "Springbank"
  b.bottle_type = "Single Malt Scotch"
  b.revealed_at = nil
end

# A few Encore Pours (wishlist entries).
top_bottles = Bottle.joins(:ratings).group(:id).order(Arel.sql("AVG(ratings.score) DESC")).limit(3)
[users[:ava], users[:ben], users[:cara]].each do |user|
  top_bottles.each do |bottle|
    BottleWishlist.find_or_create_by!(user: user, bottle: bottle)
  end
end

puts "Done. #{User.count} users, #{Meeting.count} meetings, " \
     "#{Bottle.count} bottles, #{Rating.count} ratings."
