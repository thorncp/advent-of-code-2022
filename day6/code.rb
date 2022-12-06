class DetectMessageStart
  MARKER_SIZE = 4

  def self.call(input)
    input.chars.each_cons(4).with_index do |chars, index|
      if chars.uniq.size == MARKER_SIZE
        return index + MARKER_SIZE
      end
    end
  end
end

if ARGV.any?
  puts DetectMessageStart.call(ARGF.read)
else
  require "rspec/autorun"

  RSpec.describe DetectMessageStart do
    it "detects the start of a message" do
      expect(DetectMessageStart.call("bvwbjplbgvbhsrlpgdmjqwftvncz")).to eq 5
      expect(DetectMessageStart.call("nppdvjthqldpwncqszvftbrmjlhg")).to eq 6
      expect(DetectMessageStart.call("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg")).to eq 10
      expect(DetectMessageStart.call("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw")).to eq 11
    end
  end
end
