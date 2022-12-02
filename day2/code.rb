class CalculateScore
  attr_reader :left, :right

  CHOICE_POINTS = {
    rock: 1,
    paper: 2,
    scissors: 3
  }

  WIN = 6
  DRAW = 3
  LOSE = 0

  OUTCOMES = {
    [:rock, :rock] => DRAW,
    [:rock, :paper] => WIN,
    [:rock, :scissors] => LOSE,
    [:paper, :rock] => LOSE,
    [:paper, :paper] => DRAW,
    [:paper, :scissors] => WIN,
    [:scissors, :rock] => WIN,
    [:scissors, :paper] => LOSE,
    [:scissors, :scissors] => DRAW
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

class ExecuteStrat
  STRATS = {
    [:rock, :win] => :paper,
    [:rock, :lose] => :scissors,
    [:rock, :draw] => :rock,
    [:paper, :win] => :scissors,
    [:paper, :lose] => :rock,
    [:paper, :draw] => :paper,
    [:scissors, :win] => :rock,
    [:scissors, :lose] => :paper,
    [:scissors, :draw] => :scissors
  }

  def self.call(left:, strat:)
    STRATS.fetch([left, strat])
  end
end

class CalculateTournament
  MAPPINGS = {
    "A" => :rock,
    "B" => :paper,
    "C" => :scissors,
    "X" => :lose,
    "Y" => :draw,
    "Z" => :win
  }

  def self.call(input)
    input.each_line.sum do |line|
      left, strat = line.split.map { |e| MAPPINGS.fetch(e) }
      right = ExecuteStrat.call(left: left, strat: strat)
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
      expect(CalculateScore.call(left: :rock, right: :paper)).to eq 8
      expect(CalculateScore.call(left: :paper, right: :rock)).to eq 1
      expect(CalculateScore.call(left: :scissors, right: :scissors)).to eq 6
    end
  end

  RSpec.describe ExecuteStrat do
    it "makes the desired choice based on the given strategy" do
      expect(ExecuteStrat.call(left: :rock, strat: :win)).to eq :paper
      expect(ExecuteStrat.call(left: :rock, strat: :lose)).to eq :scissors
      expect(ExecuteStrat.call(left: :rock, strat: :draw)).to eq :rock

      expect(ExecuteStrat.call(left: :paper, strat: :win)).to eq :scissors
      expect(ExecuteStrat.call(left: :paper, strat: :lose)).to eq :rock
      expect(ExecuteStrat.call(left: :paper, strat: :draw)).to eq :paper

      expect(ExecuteStrat.call(left: :scissors, strat: :win)).to eq :rock
      expect(ExecuteStrat.call(left: :scissors, strat: :lose)).to eq :paper
      expect(ExecuteStrat.call(left: :scissors, strat: :draw)).to eq :scissors
    end
  end

  RSpec.describe CalculateTournament do
    it "sums the outcomes of multiple rounds" do
      rounds = <<~TXT
        A Y
        B X
        C Z
      TXT

      expect(CalculateTournament.call(rounds)).to eq 12
    end
  end
end
