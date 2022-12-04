class Pair
  attr_reader :input

  def initialize(input)
    @input = input
  end

  def complete_overlap?
    left.cover?(right) || right.cover?(left)
  end

  def overlap?
    complete_overlap? || left.cover?(right.begin) || left.cover?(right.end)
  end

  def left
    parse_range(parts.first)
  end

  def right
    parse_range(parts.last)
  end

  private

  def parts
    input.split(",")
  end

  def parse_range(elf)
    start, stop = elf.split("-")
    Range.new(start.to_i, stop.to_i)
  end
end

class CountCompleteOverlaps
  def self.call(input)
    input.each_line
      .map { |line| Pair.new(line) }
      .count(&:complete_overlap?)
  end
end

class CountPartialOverlaps
  def self.call(input)
    input.each_line
      .map { |line| Pair.new(line) }
      .count(&:overlap?)
  end
end

if ARGV.any?
  input = ARGF.read
  puts "Complete overlap: #{CountCompleteOverlaps.call(input)}"
  puts "Partial overlap: #{CountPartialOverlaps.call(input)}"
else
  require "rspec/autorun"

  RSpec.describe Pair do
    describe "#left" do
      it "returns the range of sections covered by the left elf" do
        pair = Pair.new("2-4,6-8")
        expect(pair.left).to eq 2..4
      end
    end

    describe "#right" do
      it "returns the range of sections covered by the right elf" do
        pair = Pair.new("2-4,6-8")
        expect(pair.right).to eq 6..8
      end
    end

    describe "#complete_overlap?" do
      it "returns true if the left completely overlaps the right" do
        pair = Pair.new("2-6,3-4")
        expect(pair).to be_complete_overlap
      end

      it "returns true if the right completely overlaps the left" do
        pair = Pair.new("3-4,2-6")
        expect(pair).to be_complete_overlap
      end

      it "returns false if the two ranges do not overlap completely" do
        pair = Pair.new("2-6,4-8")
        expect(pair).to_not be_complete_overlap
      end
    end

    describe "#overlap?" do
      it "returns true if the two ranges overlap at all" do
        expect(Pair.new("5-7,7-9")).to be_overlap
        expect(Pair.new("2-8,3-7")).to be_overlap
        expect(Pair.new("6-6,4-6")).to be_overlap
        expect(Pair.new("2-6,4-8")).to be_overlap
        expect(Pair.new("7-9,5-7")).to be_overlap
        expect(Pair.new("3-7,2-8")).to be_overlap
        expect(Pair.new("4-6,6-6")).to be_overlap
        expect(Pair.new("4-8,2-6")).to be_overlap
      end

      it "returns false if the two ranges do not overlap" do
        pair = Pair.new("2-4,6-8")
        expect(pair).to_not be_overlap
      end
    end
  end

  RSpec.describe CountCompleteOverlaps do
    it "returns the number of pairs that overlap completely" do
      input = <<~TXT
        2-4,6-8
        2-3,4-5
        5-7,7-9
        2-8,3-7
        6-6,4-6
        2-6,4-8
      TXT

      expect(CountCompleteOverlaps.call(input)).to eq 2
    end
  end

  RSpec.describe CountPartialOverlaps do
    it "returns the number of pairs that overlap partially" do
      input = <<~TXT
        2-4,6-8
        2-3,4-5
        5-7,7-9
        2-8,3-7
        6-6,4-6
        2-6,4-8
      TXT

      expect(CountPartialOverlaps.call(input)).to eq 4
    end
  end
end
