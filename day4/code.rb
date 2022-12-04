class Pair
  attr_reader :input

  def initialize(input)
    @input = input
  end

  def complete_overlap?
    left.cover?(right) || right.cover?(left)
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

class CountOverlaps
  def self.call(input)
    input.each_line
      .map { |line| Pair.new(line) }
      .count(&:complete_overlap?)
  end
end

if ARGV.any?
  puts CountOverlaps.call(ARGF)
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
  end

  RSpec.describe CountOverlaps do
    it "returns the number of pairs that overlap completely" do
      input = <<~TXT
        2-4,6-8
        2-3,4-5
        5-7,7-9
        2-8,3-7
        6-6,4-6
        2-6,4-8
      TXT

      expect(CountOverlaps.call(input)).to eq 2
    end
  end
end
