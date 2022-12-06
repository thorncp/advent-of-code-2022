class DetectMessageStart
  def self.call(input, marker_size: 4)
    input.chars.each_cons(marker_size).with_index do |chars, index|
      if chars.uniq.size == marker_size
        return index + marker_size
      end
    end
  end
end

if ARGV.any?
  input = ARGF.read
  puts "Communication detected at: #{DetectMessageStart.call(input, marker_size: 4)}"
  puts "Messages starts at: #{DetectMessageStart.call(input, marker_size: 14)}"
else
  require "rspec/autorun"

  RSpec.describe DetectMessageStart do
    it "detects the start of a message" do
      expect(DetectMessageStart.call("bvwbjplbgvbhsrlpgdmjqwftvncz", marker_size: 4)).to eq 5
      expect(DetectMessageStart.call("nppdvjthqldpwncqszvftbrmjlhg", marker_size: 4)).to eq 6
      expect(DetectMessageStart.call("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", marker_size: 4)).to eq 10
      expect(DetectMessageStart.call("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", marker_size: 4)).to eq 11

      expect(DetectMessageStart.call("mjqjpqmgbljsphdztnvjfqwrcgsmlb", marker_size: 14)).to eq 19
      expect(DetectMessageStart.call("bvwbjplbgvbhsrlpgdmjqwftvncz", marker_size: 14)).to eq 23
      expect(DetectMessageStart.call("nppdvjthqldpwncqszvftbrmjlhg", marker_size: 14)).to eq 23
      expect(DetectMessageStart.call("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", marker_size: 14)).to eq 29
      expect(DetectMessageStart.call("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", marker_size: 14)).to eq 26
    end
  end
end
