require 'spec_helper'
require 'spec_helper'

describe Chouette::Line, :type => :model do
  subject { create(:line) }

  it { should belong_to(:line_referential) }
  # it { is_expected.to validate_presence_of :network }
  # it { is_expected.to validate_presence_of :company }
  it { should validate_presence_of :name }

  it "validates that transport mode and submode are matching" do
    subject.transport_mode = "bus"
    subject.transport_submode = 'undefined'

    # BUS -> no submode = OK
    expect(subject).to be_valid

    # BUS -> bus specific submode = OK
    subject.transport_submode = "nightBus"
    expect(subject).to be_valid

    # BUS -> rail specific submode = KO
    subject.transport_submode = "regionalRail"
    expect(subject).not_to be_valid

    # RAIL -> rail specific submode = OK
    subject.transport_mode = "rail"
    expect(subject).to be_valid

    # RAILS -> no submode = KO
    subject.transport_submode = nil
    expect(subject).not_to be_valid
  end

  describe 'active scopes' do
    let!(:line1) { create :line, deactivated: false }
    let!(:line2) { create :line, deactivated: true }
    let!(:line3) { create :line, deactivated: false, active_from: '01/01/2000', active_until: '02/01/2000' }
    let!(:line4) { create :line, deactivated: false, active_until: '01/02/2000' }
    let!(:line5) { create :line, deactivated: false, active_from: '02/04/2000', active_until: '02/10/2000' }
    let!(:line6) { create :line, deactivated: false, active_from: '02/04/2000' }
    let!(:line7) { create :line, deactivated: false, active_from: '02/02/2000', active_until: '02/03/2000' }

    it 'should filter lines' do
      expect(Chouette::Line.activated).to match_array [line1, line3, line4, line5, line6, line7]
      expect(Chouette::Line.deactivated).to match_array [line2]
      expect(Chouette::Line.active_after('02/02/2000'.to_date)).to match_array [line1, line5, line6, line7]
      expect(Chouette::Line.active_before('02/02/2000'.to_date)).to match_array [line1, line3, line4]
      expect(Chouette::Line.not_active_after('02/02/2000'.to_date)).to match_array [line2, line3, line4]
      expect(Chouette::Line.not_active_before('02/02/2000'.to_date)).to match_array [line2, line5, line6, line7]
      expect(Chouette::Line.active_between('02/02/2000', '02/03/2000')).to match_array [line1, line7]
      expect(Chouette::Line.not_active_between('02/02/2000'.to_date, '02/03/2000'.to_date)).to match_array [line2, line3, line4, line5, line6]
    end
  end

  describe '#url' do
    it { should allow_value("http://foo.bar").for(:url) }
    it { should allow_value("https://foo.bar").for(:url) }
    it { should allow_value("http://www.foo.bar").for(:url) }
    it { should allow_value("https://www.foo.bar").for(:url) }
    it { should allow_value("www.foo.bar").for(:url) }
  end

  describe '#color' do
    ['012345', 'ABCDEF', '18FE23', '', nil].each do |c|
      it { should allow_value(c).for(:color) }
    end

    ['01234', 'BCDEFG', '18FE233'].each do |c|
      it { should_not allow_value(c).for(:color) }
    end
  end

  describe '#text_color' do
    ['012345', 'ABCDEF', '18FE23', '', nil].each do |c|
      it { should allow_value(c).for(:color) }
    end

    ['01234', 'BCDEFG', '18FE233'].each do |c|
      it { should_not allow_value(c).for(:color) }
    end
  end

  describe '#display_name' do
    it 'should display local_id, number, name and company name' do
      display_name = "#{subject.get_objectid.local_id} - #{subject.number} - #{subject.name} - #{subject.company.try(:name)}"
      expect(subject.display_name).to eq(display_name)
    end
  end

  describe "#code" do
    it 'uses objectid.local_id' do
      expect(subject.code).to eq(subject.get_objectid.local_id)
    end
  end

  describe "#stop_areas" do
    let!(:route){create(:route, :line => subject)}
    it "should retreive route's stop_areas" do
      expect(subject.stop_areas.count).to eq(route.stop_points.count)
    end
  end

  context "#group_of_line_tokens=" do
    let!(:group_of_line1){create(:group_of_line)}
    let!(:group_of_line2){create(:group_of_line)}

    it "should return associated group_of_line ids" do
      subject.update_attributes :group_of_line_tokens => [group_of_line1.id, group_of_line2.id].join(',')
      expect(subject.group_of_lines).to include( group_of_line1)
      expect(subject.group_of_lines).to include( group_of_line2)
    end
  end

  describe "#update_attributes footnotes_attributes" do
    context "instanciate 2 footnotes without line" do
      let!( :footnote_first) {build( :footnote, :line_id => nil)}
      let!( :footnote_second) {build( :footnote, :line_id => nil)}
      it "should add 2 footnotes to the line" do
        subject.update_attributes :footnotes_attributes =>
          { Time.now.to_i => footnote_first.attributes,
            (Time.now.to_i-5) => footnote_second.attributes}
        expect(Chouette::Line.find( subject.id ).footnotes.size).to eq(2)
      end
    end
  end

  describe '#active?' do
    let(:deactivated){ nil }
    let(:active_from){ nil }
    let(:active_until){ nil }
    let(:line){ create :line, deactivated: deactivated, active_from: active_from, active_until: active_until }

    it 'should be true by default' do
      expect(line.active?).to be_truthy
      expect(line.active?(1.year.from_now)).to be_truthy
      expect(Chouette::Line.active).to include line
      expect(Chouette::Line.active(1.year.from_now)).to include line
    end

    context 'with deactivated set' do
      let(:deactivated){ true }

      it 'should be false' do
        expect(line.active?).to be_falsy
        expect(line.active?(1.year.from_now)).to be_falsy
        expect(Chouette::Line.active).to_not include line
        expect(Chouette::Line.active(1.year.from_now)).to_not include line
      end

      context 'with active_from set' do
        let(:active_from){ Time.now.to_date }

        it 'should be false' do
          expect(line.active?).to be_falsy
          expect(line.active?(1.year.from_now)).to be_falsy
          expect(Chouette::Line.active).to_not include line
          expect(Chouette::Line.active(1.year.from_now)).to_not include line
        end
      end

      context 'with active_until set' do
        let(:active_until){ 1.year.from_now.to_date }

        it 'should be false' do
          expect(line.active?).to be_falsy
          expect(line.active?(1.year.from_now)).to be_falsy
          expect(Chouette::Line.active).to_not include line
          expect(Chouette::Line.active(1.year.from_now)).to_not include line
        end

        context 'with active_from set' do
          let(:active_from){ Time.now.to_date }

          it 'should be false' do
            expect(line.active?).to be_falsy
            expect(line.active?(1.year.from_now)).to be_falsy
            expect(Chouette::Line.active).to_not include line
            expect(Chouette::Line.active(1.year.from_now)).to_not include line
          end
        end
      end
    end

    context 'with active_from set' do
      let(:active_from){ Time.now.to_date + 1 }

      it 'should depend on the date' do
        expect(line.active?).to be_falsy
        expect(line.active?(1.year.from_now)).to be_truthy
        expect(Chouette::Line.active).to_not include line
        expect(Chouette::Line.active(1.year.from_now)).to include line
      end

      context 'with active_until set' do
        let(:active_until){ Time.now.to_date + 10 }

        it 'should depend on the date' do
          expect(line.active?).to be_falsy
          expect(line.active?(Time.now.to_date + 10)).to be_truthy
          expect(line.active?(Time.now.to_date + 11)).to be_falsy
          expect(Chouette::Line.active).to_not include line
          expect(Chouette::Line.active(Time.now.to_date + 10)).to include line
          expect(Chouette::Line.active(Time.now.to_date + 11)).to_not include line
        end
      end
    end

    context 'with active_until set' do
      let(:active_until){ Time.now.to_date - 1 }

      it 'should depend on the date' do
        expect(line.active?).to be_falsy
        expect(line.active?(1.year.ago)).to be_truthy
        expect(Chouette::Line.active).to_not include line
        expect(Chouette::Line.active(1.year.ago)).to include line
      end
    end
  end
end
