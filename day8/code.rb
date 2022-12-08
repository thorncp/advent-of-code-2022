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
    return true if y == 0

    forest[x][0...y].all? { |t| t < tree }
  end

  def visible_right?(tree, x, y)
    return true if y == length - 1

    forest[x][(y + 1)..].all? { |t| t < tree }
  end

  def visible_up?(tree, x, y)
    return true if x == 0

    forest[0...x].all? { |row| row[y] < tree }
  end

  def visible_down?(tree, x, y)
    return true if x == height - 1

    forest[(x + 1)..].all? { |row| row[y] < tree }
  end

  def length
    forest.first.size
  end

  def height
    forest.size
  end
end

class CalcScenicScore
  attr_reader :forest, :x, :y

  def self.call(forest, x, y)
    new(forest, x, y).call
  end

  def initialize(forest, x, y)
    @forest = forest
    @x = x
    @y = y
  end

  def call
    left_score * right_score * up_score * down_score
  end

  private

  def left_score
    return 0 if y == 0

    obstacle = (y - 1).downto(0).find { |yy| forest[x][yy] >= tree } || 0

    y - obstacle
  end

  def right_score
    return 0 if y == length - 1

    obstacle = (y + 1).upto(length - 1).find { |yy| forest[x][yy] >= tree } || length - 1

    obstacle - y
  end

  def up_score
    return 0 if x == 0

    obstacle = (x - 1).downto(0).find { |xx| forest[xx][y] >= tree } || 0

    x - obstacle
  end

  def down_score
    return 0 if x == height - 1

    obstacle = (x + 1).upto(height - 1).find { |xx| forest[xx][y] >= tree } || height - 1

    obstacle - x
  end

  def length
    forest.first.size
  end

  def height
    forest.size
  end

  def tree
    forest[x][y]
  end
end

class CalcMaxScenicScore
  def self.call(forest)
    forest.length.times.flat_map do |x|
      forest[x].length.times.map do |y|
        CalcScenicScore.call(forest, x, y)
      end
    end.max
  end
end

if ARGV.any?
  forest = ParseForest.call(ARGF)
  visible_trees = CountVisibleTrees.call(forest)
  max_score = CalcMaxScenicScore.call(forest)
  puts "Visible trees: #{visible_trees}"
  puts "Max score: #{max_score}"
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

  RSpec.describe CalcScenicScore do
    it "calculates the scenic score for a tree" do
      forest = [
        [3, 0, 3, 7, 3],
        [2, 5, 5, 1, 2],
        [6, 5, 3, 3, 2],
        [3, 3, 5, 4, 9],
        [3, 5, 3, 9, 0]
      ]

      expect(CalcScenicScore.call(forest, 1, 2)).to eq 4
      expect(CalcScenicScore.call(forest, 3, 2)).to eq 8
    end
  end

  RSpec.describe CalcMaxScenicScore do
    it "finds the highest scenic score in the forest" do
      forest = [
        [3, 0, 3, 7, 3],
        [2, 5, 5, 1, 2],
        [6, 5, 3, 3, 2],
        [3, 3, 5, 4, 9],
        [3, 5, 3, 9, 0]
      ]

      expect(CalcMaxScenicScore.call(forest)).to eq 8
    end
  end
end
