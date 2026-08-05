FactoryBot.define do
  factory :meeting do
    association :bottle_bringer, factory: :user
    # Offset well past the fixed trait dates (:past -7d, :upcoming +7d) so the
    # unique-date sequence can never collide with them.
    sequence(:date) { |n| Date.current + 30.days + n.days }
    is_flight { false }
    
    trait :flight_night do
      is_flight { true }
      bottle_bringer { nil }
      
      after(:create) do |meeting|
        create_list(:bottle, 3, meeting: meeting)
      end
    end
    
    trait :with_bottle do
      after(:create) do |meeting|
        create(:bottle, meeting: meeting, user: meeting.bottle_bringer)
      end
    end
    
    trait :past do
      date { 1.week.ago }
    end
    
    trait :upcoming do
      date { 1.week.from_now }
    end
  end
end
