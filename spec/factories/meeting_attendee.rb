FactoryBot.define do
  factory :meeting_attendee do
    association :meeting
    association :user
  end
end
