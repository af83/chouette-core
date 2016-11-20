FactoryGirl.define do
  factory :workbench do
    sequence(:name) { |n| "Workbench #{n}" }

    association :organisation, :factory => :organisation
    association :line_referential
    association :stop_area_referential
  end
end
