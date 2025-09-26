FactoryBot.define do
  factory :meeting do
    association :bottle_bringer, factory: :user
    date { Date.today }
  end
end
