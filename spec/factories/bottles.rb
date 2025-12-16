FactoryBot.define do
  factory :bottle do
    association :user
    association :meeting
    sequence(:name) { |n| "Lagavulin #{n}" }
    distillery { "Lagavulin" }
    age { 16 }
    bottle_type { "Single Malt Scotch" }
    
    trait :with_ratings do
      after(:create) do |bottle|
        create_list(:rating, 3, bottle: bottle)
      end
    end
    
    trait :revealed do
      revealed_at { 1.day.ago }
    end
    
    trait :unrevealed do
      revealed_at { nil }
    end
  end
end
