class ParseForest
  def self.call(input)
    input.each_line.map do |line|
      line.strip.chars.map(&:to_i)
    end
  end
end

class CountVisibleTrees
  attr_reader :forest

  def self.call(forest)
    new(forest).call
  end

  def initialize(forest)
    @forest = forest
  end

  def call
    forest.each_with_index.sum do |row, x|
      row.each_with_index.count do |tree, y|
        visible?(tree, x, y)
      end
    end
  end

  private

  def visible?(tree, x, y)
    visible_left?(tree, x, y) ||
      visible_right?(tree, x, y) ||
      visible_up?(tree, x, y) ||
      visible_down?(tree, x, y)
  end

  def visible_left?(tree, x, y)
    return true if x == 0

    forest[x][0...y].all? { |t| t < tree }
  end

  def visible_right?(tree, x, y)
    return true if x == length - 1

    forest[x][(y + 1)..].all? { |t| t < tree }
  end

  def visible_up?(tree, x, y)
    return true if y == 0

    forest[0...x].all? { |row| row[y] < tree }
  end

  def visible_down?(tree, x, y)
    return true if y == height - 1

    forest[(x + 1)..].all? { |row| row[y] < tree }
  end

  def length
    forest.first.size
  end

  def height
    forest.size
  end
end

if ARGV.any?
  forest = ParseForest.call(ARGF)
  visible_trees = CountVisibleTrees.call(forest)
  puts "Visible trees: #{visible_trees}"
else
  require "rspec/autorun"

  RSpec.describe ParseForest do
    it "parses text into a matrix" do
      input = <<~TXT
        30373
        25512
        65332
        33549
        35390
      TXT

      forest = ParseForest.call(input)

      expect(forest).to eq [
        [3, 0, 3, 7, 3],
        [2, 5, 5, 1, 2],
        [6, 5, 3, 3, 2],
        [3, 3, 5, 4, 9],
        [3, 5, 3, 9, 0]
      ]
    end
  end

  RSpec.describe CountVisibleTrees do
    it "counts the visible trees" do
      forest = [
        [3, 0, 3, 7, 3],
        [2, 5, 5, 1, 2],
        [6, 5, 3, 3, 2],
        [3, 3, 5, 4, 9],
        [3, 5, 3, 9, 0]
      ]

      expect(CountVisibleTrees.call(forest)).to eq 21
    end
  end
end
