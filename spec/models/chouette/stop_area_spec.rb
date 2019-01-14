# coding: utf-8
require 'spec_helper'

describe Chouette::StopArea, :type => :model do
  subject { create(:stop_area) }

  let!(:quay) { create :stop_area, :zdep }
  let!(:commercial_stop_point) { create :stop_area, :lda }
  let!(:stop_place) { create :stop_area, :zdlp }

  it { should belong_to(:stop_area_referential) }
  it { should validate_presence_of :name }
  it { should validate_presence_of :kind }
  it { should validate_numericality_of :latitude }
  it { should validate_numericality_of :longitude }

  describe "#time_zone" do
    it "should validate the value is a correct canonical timezone" do
      expect(build(:stop_area, time_zone: nil)).to be_valid
      expect(build(:stop_area, time_zone: "Europe/Lisbon")).to be_valid
      expect(build(:stop_area, time_zone: "Portugal")).to_not be_valid
    end
  end

  describe "#area_type" do
    it "should validate the value is correct regarding to the kind" do
      expect(build(:stop_area, kind: :commercial, area_type: :gdl)).to be_valid
      expect(build(:stop_area, kind: :non_commercial, area_type: :relief)).to be_valid
      expect(build(:stop_area, kind: :commercial, area_type: :relief)).to_not be_valid
      expect(build(:stop_area, kind: :non_commercial, area_type: :gdl)).to_not be_valid
    end
  end

  describe "#objectid" do
    it "should be uniq in a StopAreaReferential" do
      subject
      expect{ create(:stop_area, stop_area_referential: subject.stop_area_referential, objectid: subject.objectid) }.to raise_error ActiveRecord::RecordInvalid
      expect{ build(:stop_area, objectid: subject.objectid) }.to_not raise_error
    end
  end

  describe "#registration_number" do
    let(:registration_number){ nil }
    let(:registration_number_format){ nil }
    let(:stop_area_referential){ create :stop_area_referential, registration_number_format: registration_number_format}
    let(:stop_area){ build :stop_area, stop_area_referential: stop_area_referential, registration_number: registration_number}
    context "without registration_number_format on the StopAreaReferential" do
      it "should not generate a registration_number" do
        stop_area.save!
        expect(stop_area.registration_number).to_not be_present
      end

      it "should not validate the registration_number format" do
        stop_area.registration_number = "1234455"
        expect(stop_area).to be_valid
      end

      it "should not validate the registration_number uniqueness" do
        stop_area.registration_number = "1234455"
        create :stop_area, stop_area_referential: stop_area_referential, registration_number: stop_area.registration_number
        expect(stop_area).to be_valid
      end
    end

    context "with a registration_number_format on the StopAreaReferential" do
      let(:registration_number_format){ "XXX" }

      it "should generate a registration_number" do
        stop_area.save!
        expect(stop_area.registration_number).to be_present
        expect(stop_area.registration_number).to match /[A-Z]{3}/
      end

      context "with a previous stop_area" do
        it "should generate a registration_number" do
          create :stop_area, stop_area_referential: stop_area_referential, registration_number: "AAA"
          stop_area.save!
          expect(stop_area.registration_number).to be_present
          expect(stop_area.registration_number).to eq "AAB"
        end

        it "should generate a registration_number" do
          create :stop_area, stop_area_referential: stop_area_referential, registration_number: "ZZZ"
          stop_area.save!
          expect(stop_area.registration_number).to be_present
          expect(stop_area.registration_number).to eq "AAA"
        end

        it "should generate a registration_number" do
          create :stop_area, stop_area_referential: stop_area_referential, registration_number: "AAA"
          create :stop_area, stop_area_referential: stop_area_referential, registration_number: "ZZZ"
          stop_area.save!
          expect(stop_area.registration_number).to be_present
          expect(stop_area.registration_number).to eq "AAB"
        end
      end

      it "should validate the registration_number format" do
        stop_area.registration_number = "1234455"
        expect(stop_area).to_not be_valid
        stop_area.registration_number = "ABC"
        expect(stop_area).to be_valid
        expect{ stop_area.save! }.to_not raise_error
      end

      it "should validate the registration_number uniqueness" do
        stop_area.registration_number = "ABC"
        create :stop_area, stop_area_referential: stop_area_referential, registration_number: stop_area.registration_number
        expect(stop_area).to_not be_valid

        stop_area.registration_number = "ABD"
        create :stop_area, registration_number: stop_area.registration_number
        expect(stop_area).to be_valid
      end
    end
  end

  context "create all types of stop areas" do
    it "should validate kind of stop areas" do
      expect(build(:stop_area, :zdep)).to be_valid
      expect(build(:stop_area, :zdlp)).to be_valid
      expect(build(:stop_area, :lda)).to be_valid
      expect(build(:stop_area, :gdl)).to be_valid
      expect(build(:stop_area, :deposit)).to be_valid
      expect(build(:stop_area, :border)).to be_valid
      expect(build(:stop_area, :service_area)).to be_valid
      expect(build(:stop_area, :relief)).to be_valid
      expect(build(:stop_area, :other)).to be_valid
    end
  end

  context "update" do
    let(:commercial) {create :stop_area, :zdep}
    let(:non_commercial) {create :stop_area, :deposit}

    context "commercial kind" do
      it "should be updatable" do
        commercial.name = "new name"
        commercial.save
        expect(commercial.reload).to be_valid
      end 
    end

    context "non commercial kind" do
      it "should be updatable" do
        non_commercial.name = "new name"
        non_commercial.save
        expect(non_commercial.reload).to be_valid
      end 
    end
  end

  describe "#parent" do

    let(:stop_area) { FactoryGirl.build :stop_area, parent: FactoryGirl.build(:stop_area) }

    it "is valid when parent has an 'higher' type" do
      stop_area.area_type = 'zdep'
      stop_area.parent.area_type = 'zdlp'

      stop_area.valid?
      expect(stop_area.errors).to_not have_key(:parent_id)
    end

    it "is valid when parent has the same kind" do
      stop_area.area_type = 'zdep' # Ensure right parent_area_type
      stop_area.parent.area_type = 'zdlp' # Ensure right parent_area_type
      stop_area.kind = 'commercial'
      stop_area.parent.kind = 'commercial'
      
      stop_area.valid?
      expect(stop_area.errors).to_not have_key(:parent_id)
    end

    it "is valid when parent is undefined" do
      stop_area.parent = nil

      stop_area.valid?
      expect(stop_area.errors).to_not have_key(:parent_id)
    end

    it "isn't valid when parent has the same type" do
      stop_area.parent.area_type = stop_area.area_type = 'zdep'

      stop_area.valid?
      expect(stop_area.errors).to have_key(:parent_id)
    end

    it "isn't valid when parent has a lower type" do
      stop_area.area_type = 'lda'
      stop_area.parent.area_type = 'zdep'

      stop_area.valid?
      expect(stop_area.errors).to have_key(:parent_id)
    end

    it "isn't valid when parent has a different kind" do
      stop_area.area_type = 'zdep' # Ensure right parent_area_type
      stop_area.parent.area_type = 'zdlp' # Ensure right parent_area_type
      stop_area.kind = 'commercial'
      stop_area.parent.kind = 'non_commercial'

      stop_area.valid?
      expect(stop_area.errors).to have_key(:parent_id)
    end

    it "use parent area type label in validation error message" do
      stop_area.area_type = 'zdep'
      stop_area.parent.area_type = 'zdep'

      stop_area.valid?
      expect(stop_area.errors[:parent_id].first).to include(Chouette::AreaType.find(stop_area.parent.area_type).label)
    end

  end

  describe '#waiting_time' do

    let(:stop_area) { FactoryGirl.build :stop_area }

    it 'can be nil' do
      stop_area.waiting_time = nil
      expect(stop_area).to be_valid
    end

    it 'can be zero' do
      stop_area.waiting_time = 0
      expect(stop_area).to be_valid
    end

    it 'can be positive' do
      stop_area.waiting_time = 120
      expect(stop_area).to be_valid
    end

    it "can't be negative" do
      stop_area.waiting_time = -1
      expect(stop_area).to_not be_valid
    end

  end

end
