class CountCalories
  attr_reader :input

  def self.call(input)
    new(input).call
  end

  def initialize(input)
    @input = input
  end

  def call
    foods_summed_by_elf
  end

  private

  def foods_summed_by_elf
    foods_sliced_by_elf.map do |foods|
      foods.map(&:to_i).sum
    end
  end

  def foods_sliced_by_elf
    lines.slice_when do |line, _next_line|
      line.empty?
    end
  end

  def lines
    input.lines(chomp: true)
  end
end

class FindMax
  def self.call(input)
    input.max
  end
end

class FindTopThree
  def self.call(input)
    input.sort.last(3).sum
  end
end

if ARGV.any?
  calories = CountCalories.call(ARGF.read)
  puts "Top elf: #{FindMax.call(calories)}"
  puts "Top three: #{FindTopThree.call(calories)}"
else
  require "rspec/autorun"

  RSpec.describe CountCalories do
    it "totals calories held by elves" do
      input = <<~TXT
        1000
        2000
        3000

        4000

        5000
        6000

        7000
        8000
        9000

        10000
      TXT

      calories = CountCalories.call(input)

      expect(calories).to eq [
        6000,
        4000,
        11000,
        24000,
        10000
      ]
    end
  end

  RSpec.describe FindMax do
    it "returns the maximum value of a hash" do
      input = [
        6000,
        4000,
        11000,
        24000,
        10000
      ]

      max = FindMax.call(input)

      expect(max).to eq 24000
    end
  end

  RSpec.describe FindTopThree do
    it "returns the sum of the three highest values" do
      input = [
        6000,
        4000,
        11000,
        24000,
        10000
      ]

      max = FindTopThree.call(input)

      expect(max).to eq 45000
    end
  end
end
