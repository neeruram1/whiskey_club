FactoryBot.define do
  factory :rating do
    association :bottle
    association :user
    score { 4 }
    comment { "Great whiskey!" }
    
    trait :excellent do
      score { 5 }
    end
    
    trait :poor do
      score { 1 }
    end
  end
end
