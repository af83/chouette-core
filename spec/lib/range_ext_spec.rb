require 'range_ext'
RSpec.describe Range do
  describe "#intersection" do
    it "is nil (sic) for two distinct ranges" do
      expect( (1..2).intersection(3..4) ).to be_nil
    end

    it "is the smaller of two if one is part of the other" do
      expect( (1..2).intersection(0..3) ).to eq 1..2
      expect( (0..2).intersection(1..2) ).to eq 1..2
    end

    it "is the intersection otherwise" do
      expect( (1..3) & (2..4) ).to eq 2..3
      expect( (2..4) & (1..3) ).to eq 2..3
    end
  end

  describe "intersect?" do
    it 'is true when the given range includes begin' do
      expect( (2..4).intersect? (1..3) ).to be_truthy
    end

    it 'is true when the given range includes end' do
      expect( (2..4).intersect? (3..5) ).to be_truthy
    end

    it 'is true when the given range includes both begin and end' do
      expect( (2..4).intersect? (1..5) ).to be_truthy
    end

    it 'is true when the given range is the same' do
      expect( (2..4).intersect? (2..4) ).to be_truthy
    end

    it 'is false when the given range is after' do
      expect( (2..4).intersect? (5..7) ).to be_falsey
    end

    it 'is false when the given range is before' do
      expect( (2..4).intersect? (0..2) ).to be_falsey
    end
  end

  context "remove" do
    it "is unchanged when the given range has no intersection" do
      expect( (1..2).remove(3..4) ).to eq 1..2
      expect( (3..4).remove(1..2) ).to eq 3..4
    end

    it "is nil for two equal ranges" do
      expect( (1..2).remove(1..2) ).to be_empty
    end

    it "is the begin of the range when given range intersect the end" do
      expect( (5..10).remove(8..15) ).to eq [5..7]
    end

    it "is the end of the range when given range intersect the begin" do
      expect( (5..10).remove(1..6) ).to eq [7..10]
    end

    it "is the two remaing ranges when given range is the middle" do
      expect( (1..10).remove(4..6) ).to eq [1..3, 7..10]
    end
  end
end
