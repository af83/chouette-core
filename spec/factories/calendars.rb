FactoryGirl.define do
  factory :calendar do
    sequence(:name) { |n| "Calendar #{n}" }
    date_ranges { [generate(:date_range)] }
    sequence(:dates) { |n| [ Date.yesterday - n, Date.yesterday - 2*n ] }
    sequence(:excluded_dates) { |n| [ Date.yesterday - n.month, Date.yesterday - (2*n).month ] }
    shared false
    organisation
    workgroup
  end

  sequence :date_range do |n|
    date = Date.today + 2*n
    date..(date+1)
  end
end
