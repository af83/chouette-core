RSpec.describe Chouette::PurchaseWindow, :type => :model do
  let(:referential) {create(:referential)}
  subject  { create(:purchase_window, referential: referential) }

  it { should belong_to(:referential) }
  it { is_expected.to validate_presence_of(:name) }

  describe 'validations' do
    it 'validates and date_ranges do not overlap' do
      expect(build(:purchase_window, referential: referential,date_ranges: [Date.today..Date.today + 10.day, Date.yesterday..Date.tomorrow])).to_not be_valid
      # expect(build(periods: [Date.today..Date.today + 10.day, Date.yesterday..Date.tomorrow ])).to_not be_valid
    end
  end

  describe 'before_validation' do
    let(:purchase_window) { build(:purchase_window, referential: referential, date_ranges: []) }

    it 'shoud fill date_ranges with date ranges' do
      expected_range = Date.today..Date.tomorrow
      purchase_window.date_ranges << expected_range
      purchase_window.valid?

      expect(purchase_window.date_ranges.map { |period| period.begin..period.end }).to eq([expected_range])
    end
  end

end
