FactoryGirl.define do
  factory :workgroup do
    sequence(:name) { |n| "Workgroup ##{n}" }
    association :line_referential
    association :stop_area_referential
  end
end
