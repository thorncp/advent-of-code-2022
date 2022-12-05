class ParseStacks
  def self.call(input)
    stacks = Hash.new { |h, k| h[k] = [] }

    input.each_line do |line|
      break if line.strip.empty?

      line.scan(/\s{4}|\[\w\]/).each_with_index do |item, index|
        if !item.strip.empty?
          stacks[index + 1].prepend(item[1])
        end
      end
    end

    stacks
  end
end

class ExecuteMoveOrder
  def self.call(stacks:, order:)
    match = order.match(/move (?<count>\d+) from (?<source>\d+) to (?<destination>\d+)/)
    source = stacks[match[:source].to_i]
    destination = stacks[match[:destination].to_i]
    foo = source.pop(match[:count].to_i)
    destination.push(*foo)

    stacks
  end
end

class UnloadCrates
  def self.call(stacks:, input:)
    input.each_line do |line|
      if /move/.match?(line)
        stacks = ExecuteMoveOrder.call(stacks: stacks, order: line)
      end
    end

    stacks
  end
end

class ObserveTopCrates
  def self.call(stacks)
    stacks.sort_by { |k, _| k }.map { |_, v| v.last }.join
  end
end

if ARGV.any?
  stacks = ParseStacks.call(ARGF)
  stacks = UnloadCrates.call(stacks: stacks, input: ARGF)
  puts ObserveTopCrates.call(stacks)
else
  require "rspec/autorun"

  RSpec.describe ParseStacks do
    it "parses input into a collection of stacks" do
      input = <<~TXT
            [D]    
        [N] [C]    
        [Z] [M] [P]
         1   2   3 
      TXT

      expect(ParseStacks.call(input)).to eq(
        1 => %w[Z N],
        2 => %w[M C D],
        3 => %w[P]
      )
    end
  end

  RSpec.describe ExecuteMoveOrder do
    it "moves crates from one stack to another" do
      stacks = {
        1 => %w[Z N],
        2 => %w[M C D],
        3 => %w[P]
      }

      expect(ExecuteMoveOrder.call(stacks: stacks, order: "move 1 from 2 to 1")).to eq(
        1 => %w[Z N D],
        2 => %w[M C],
        3 => %w[P]
      )
    end

    it "preserves the order of the crates" do
      stacks = {
        1 => %w[Z N D],
        2 => %w[M C],
        3 => %w[P]
      }

      expect(ExecuteMoveOrder.call(stacks: stacks, order: "move 3 from 1 to 3")).to eq(
        1 => %w[],
        2 => %w[M C],
        3 => %w[P Z N D]
      )
    end
  end

  RSpec.describe UnloadCrates do
    it "processes several move orders" do
      input = <<~TXT
        move 1 from 2 to 1
        move 3 from 1 to 3
        move 2 from 2 to 1
        move 1 from 1 to 2
      TXT
      stacks = {
        1 => %w[Z N],
        2 => %w[M C D],
        3 => %w[P]
      }

      updated_stacks = UnloadCrates.call(stacks: stacks, input: input)

      expect(updated_stacks).to eq(
        1 => %w[M],
        2 => %w[C],
        3 => %w[P Z N D]
      )
    end
  end

  RSpec.describe ObserveTopCrates do
    it "returns the top crate in each stack" do
      stacks = {
        1 => %w[C],
        2 => %w[M],
        3 => %w[P D N Z]
      }

      expect(ObserveTopCrates.call(stacks)).to eq "CMZ"
    end
  end
end
