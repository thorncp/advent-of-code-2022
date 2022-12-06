class DetectCommunication
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
  puts "Communication detected at: #{DetectCommunication.call(input, marker_size: 4)}"
  puts "Messages starts at: #{DetectCommunication.call(input, marker_size: 14)}"
else
  require "rspec/autorun"

  RSpec.describe DetectCommunication do
    it "detects the start of a message" do
      expect(DetectCommunication.call("bvwbjplbgvbhsrlpgdmjqwftvncz", marker_size: 4)).to eq 5
      expect(DetectCommunication.call("nppdvjthqldpwncqszvftbrmjlhg", marker_size: 4)).to eq 6
      expect(DetectCommunication.call("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", marker_size: 4)).to eq 10
      expect(DetectCommunication.call("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", marker_size: 4)).to eq 11

      expect(DetectCommunication.call("mjqjpqmgbljsphdztnvjfqwrcgsmlb", marker_size: 14)).to eq 19
      expect(DetectCommunication.call("bvwbjplbgvbhsrlpgdmjqwftvncz", marker_size: 14)).to eq 23
      expect(DetectCommunication.call("nppdvjthqldpwncqszvftbrmjlhg", marker_size: 14)).to eq 23
      expect(DetectCommunication.call("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", marker_size: 14)).to eq 29
      expect(DetectCommunication.call("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", marker_size: 14)).to eq 26
    end
  end
end
