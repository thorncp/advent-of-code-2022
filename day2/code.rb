class CalculateScore
  attr_reader :left, :right

  CHOICE_POINTS = {
    "X" => 1,
    "Y" => 2,
    "Z" => 3
  }

  WIN = 6
  DRAW = 3
  LOSE = 0

  OUTCOMES = {
    ["A", "X"] => DRAW,
    ["A", "Y"] => WIN,
    ["A", "Z"] => LOSE,
    ["B", "X"] => LOSE,
    ["B", "Y"] => DRAW,
    ["B", "Z"] => WIN,
    ["C", "X"] => WIN,
    ["C", "Y"] => LOSE,
    ["C", "Z"] => DRAW
  }

  def self.call(left:, right:)
    new(left: left, right: right).call
  end

  def initialize(left:, right:)
    @left = left
    @right = right
  end

  def call
    outcome + choice_points
  end

  private

  def outcome
    OUTCOMES.fetch([left, right])
  end

  def choice_points
    CHOICE_POINTS.fetch(right)
  end
end

class CalculateTournament
  def self.call(input)
    input.each_line.sum do |line|
      left, right = line.split
      CalculateScore.call(left: left, right: right)
    end
  end
end

if ARGV.any?
  puts CalculateTournament.call(ARGF)
else
  require "rspec/autorun"

  RSpec.describe CalculateScore do
    it "calculates a score for a round of rock paper scissors, from the right side's perspective" do
      expect(CalculateScore.call(left: "A", right: "Y")).to eq 8
      expect(CalculateScore.call(left: "B", right: "X")).to eq 1
      expect(CalculateScore.call(left: "C", right: "Z")).to eq 6
    end
  end

  RSpec.describe CalculateTournament do
    it "sums the outcomes of multiple rounds" do
      rounds = <<~TXT
        A Y
        B X
        C Z
      TXT

      expect(CalculateTournament.call(rounds)).to eq 15
    end
  end
end
