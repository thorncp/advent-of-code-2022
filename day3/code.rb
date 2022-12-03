class Rucksack
  attr_reader :contents

  def initialize(contents)
    @contents = contents
  end

  def compartment_one
    items[0...compartment_size]
  end

  def compartment_size
    contents.length / 2
  end

  def compartment_two
    items[compartment_size..]
  end

  def items
    contents.chars
  end
end

class FindDuplicateItem
  def self.call(rucksack)
    (rucksack.compartment_one & rucksack.compartment_two).first
  end
end

class DeterminePriority
  PRIORITIES = ("a".."z").to_a.concat(("A".."Z").to_a).zip((1..52).to_a).to_h

  def self.call(item)
    PRIORITIES.fetch(item)
  end
end

class FindGroupBadge
  def self.call(rucksacks)
    rucksacks
      .map(&:items)
      .reduce(&:&)
      .first
  end
end

class SumGroupBadges
  def self.call(input)
    input.each_line
      .map { |l| Rucksack.new(l) }
      .each_slice(3)
      .map { |g| FindGroupBadge.call(g) }
      .map { |i| DeterminePriority.call(i) }
      .sum
  end
end

if ARGV.any?
  puts SumGroupBadges.call(ARGF)
else
  require "rspec/autorun"

  RSpec.describe Rucksack do
    describe "#compartment_one" do
      it "returns the first compartment's contents" do
        rucksack = Rucksack.new("aBcdBe")
        expect(rucksack.compartment_one).to eq %w[a B c]
      end
    end

    describe "#compartment_size" do
      it "returns the size of a compartment" do
        rucksack = Rucksack.new("aBcdBe")
        expect(rucksack.compartment_size).to eq(3)
      end
    end

    describe "#compartment_two" do
      it "returns the second compartment's contents" do
        rucksack = Rucksack.new("aBcdBe")
        expect(rucksack.compartment_two).to eq %w[d B e]
      end
    end
  end

  RSpec.describe FindDuplicateItem do
    it "finds the duplicate item in a rucksack" do
      rucksack = Rucksack.new("aBcdBe")
      expect(FindDuplicateItem.call(rucksack)).to eq("B")
    end
  end

  RSpec.describe DeterminePriority do
    it "finds the priority of an item" do
      expect(DeterminePriority.call("a")).to eq(1)
      expect(DeterminePriority.call("p")).to eq(16)
      expect(DeterminePriority.call("v")).to eq(22)
      expect(DeterminePriority.call("z")).to eq(26)
      expect(DeterminePriority.call("A")).to eq(27)
      expect(DeterminePriority.call("L")).to eq(38)
      expect(DeterminePriority.call("P")).to eq(42)
      expect(DeterminePriority.call("Z")).to eq(52)
    end
  end

  RSpec.describe FindGroupBadge do
    it "finds the common item of group" do
      rucksacks = [
        Rucksack.new("vJrwpWtwJgWrhcsFMMfFFhFp"),
        Rucksack.new("jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL"),
        Rucksack.new("PmmdzqPrVvPwwTWBwg")
      ]

      expect(FindGroupBadge.call(rucksacks)).to eq("r")
    end
  end

  RSpec.describe SumGroupBadges do
    it "sums the priorities of duplicate items in many rucksacks" do
      input = <<~TXT
        vJrwpWtwJgWrhcsFMMfFFhFp
        jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
        PmmdzqPrVvPwwTWBwg
        wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
        ttgJtRGJQctTZtZT
        CrZsJsPPZsGzwwsLwLmpwMDw
      TXT

      expect(SumGroupBadges.call(input)).to eq(70)
    end
  end
end
