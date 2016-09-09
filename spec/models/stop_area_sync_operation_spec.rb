require 'rails_helper'

RSpec.describe StopAreaSyncOperation, :type => :model do
  it 'should have a valid factory' do
    expect(FactoryGirl.build(:stop_area_sync_operation)).to be_valid
  end

  it { is_expected.to belong_to(:stop_area_referential_sync) }
end
