class CountCalories
  def self.call(input)
    elf = 1
    elves = Hash.new(0)

    input.each_line do |line|
      line.strip!

      if line.empty?
        elf += 1
      else
        elves[elf] += Integer(line)
      end
    end

    elves
  end
end

class FindMax
  def self.call(input)
    input.values.max
  end
end

class FindTopThree
  def self.call(input)
    input.values.sort.last(3).sum
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

      expect(calories).to eq(
        1 => 6000,
        2 => 4000,
        3 => 11000,
        4 => 24000,
        5 => 10000
      )
    end
  end

  RSpec.describe FindMax do
    it "returns the maximum value of a hash" do
      input = {
        1 => 6000,
        2 => 4000,
        3 => 11000,
        4 => 24000,
        5 => 10000
      }

      max = FindMax.call(input)

      expect(max).to eq 24000
    end
  end

  RSpec.describe FindTopThree do
    it "returns the sum of the three highest values" do
      input = {
        1 => 6000,
        2 => 4000,
        3 => 11000,
        4 => 24000,
        5 => 10000
      }

      max = FindTopThree.call(input)

      expect(max).to eq 45000
    end
  end
end