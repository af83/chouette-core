FactoryGirl.define do
  factory :generic_attribute_control_min_max, class: 'GenericAttributeControl::MinMax' do
    sequence(:name) { |n| "MinMax control #{n}" }
    association :compliance_control_set
    minimum 90
    maximum 120
    target "route#name"
  end

  factory :generic_attribute_control_pattern, class: 'GenericAttributeControl::Pattern' do
    sequence(:name) { |n| "Pattern control #{n}" }
    association :compliance_control_set
    pattern "^(.)*$"
    target "route#name"
  end

  factory :generic_attribute_control_uniqueness, class: 'GenericAttributeControl::Uniqueness' do
    sequence(:name) { |n| "Uniqueness control #{n}" }
    association :compliance_control_set
    target "route#name"
  end
end
