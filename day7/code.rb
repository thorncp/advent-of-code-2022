class SumTargetDirectorySizes
  def self.call(tree:, size_cap:)
    if tree.size <= size_cap
      tree.size + tree.directories.map { |child| call(tree: child, size_cap: size_cap) }.sum
    else
      tree.directories.map { |child| call(tree: child, size_cap: size_cap) }.sum
    end
  end
end

class ParseTerminalHistory
  attr_reader :input, :tree, :working_directory, :command

  def self.call(input)
    new(input).call
  end

  def initialize(input)
    @input = input
    @tree = Tree.new(name: "/")
    @working_directory = tree
  end

  def call
    input.each_line do |line|
      if line.start_with?("$")
        @command = nil
        case line.strip
        when "$ cd /"
          @working_directory = tree
        when "$ cd .."
          @working_directory = working_directory.parent
        when %r{\$ cd (.+)}
          @working_directory = working_directory[$1]
        when "$ ls"
          @command = :ls
        end
      elsif command == :ls
        if line.start_with?("dir")
          working_directory.add_directory(name: line[4..].strip)
        else
          size, name = line.split(" ", 2)
          working_directory.add_file(name: name.strip, size: size.to_i)
        end
      end
    end

    tree
  end
end

class Tree
  attr_reader :name, :files, :directories, :parent, :size

  def initialize(name:, parent: nil)
    @name = name
    @parent = parent
    @files = []
    @directories = []
    @size = 0
  end

  def add_directory(name:)
    directories << Tree.new(name: name, parent: self)
  end

  def add_file(name:, size:)
    file = FileEntry.new(name: name, size: size)
    files << file
    propogate_file_size_change(file)
  end

  def [](name)
    directories.find { |d| d.name == name }
  end

  protected

  def propogate_file_size_change(file, tree: parent)
    @size += file.size
    parent&.propogate_file_size_change(file)
  end
end

FileEntry = Struct.new(:name, :size, keyword_init: true)

if ARGV.any?
  tree = ParseTerminalHistory.call(ARGF)
  puts SumTargetDirectorySizes.call(tree: tree, size_cap: 100000)
else
  require "rspec/autorun"

  RSpec.describe ParseTerminalHistory do
    it "parses terminal history into a directory tree" do
      input = <<~TXT
        $ cd /
        $ ls
        dir a
        14848514 b.txt
        8504156 c.dat
        dir d
        $ cd a
        $ ls
        dir e
        29116 f
        2557 g
        62596 h.lst
        $ cd e
        $ ls
        584 i
        $ cd ..
        $ cd ..
        $ cd d
        $ ls
        4060174 j
        8033020 d.log
        5626152 d.ext
        7214296 k
      TXT

      tree = ParseTerminalHistory.call(input)

      expect(tree.name).to eq "/"
      expect(tree.directories.map(&:name)).to eq ["a", "d"]
      expect(tree.files.map(&:name)).to eq ["b.txt", "c.dat"]

      expect(tree["a"].directories.map(&:name)).to eq ["e"]
      expect(tree["a"].files.map(&:name)).to eq ["f", "g", "h.lst"]

      expect(tree["a"]["e"].directories.map(&:name)).to be_empty
      expect(tree["a"]["e"].files.map(&:name)).to eq ["i"]

      expect(tree["d"].directories.map(&:name)).to be_empty
      expect(tree["d"].files.map(&:name)).to eq ["j", "d.log", "d.ext", "k"]
    end
  end

  RSpec.describe SumTargetDirectorySizes do
    it "sums the sizes of directories less than the given size constraint" do
      input = <<~TXT
        $ cd /
        $ ls
        dir a
        14848514 b.txt
        8504156 c.dat
        dir d
        $ cd a
        $ ls
        dir e
        29116 f
        2557 g
        62596 h.lst
        $ cd e
        $ ls
        584 i
        $ cd ..
        $ cd ..
        $ cd d
        $ ls
        4060174 j
        8033020 d.log
        5626152 d.ext
        7214296 k
      TXT

      tree = ParseTerminalHistory.call(input)

      expect(SumTargetDirectorySizes.call(tree: tree, size_cap: 100000)).to eq 95437
    end
  end

  RSpec.describe Tree do
    describe "#add_directory" do
      it "adds a directory" do
        tree = Tree.new(name: "/")

        tree.add_directory(name: "a")

        expect(tree.directories.size).to eq 1
        expect(tree.directories.first.name).to eq "a"
        expect(tree.directories.first.parent).to eq tree
      end
    end

    describe "#add_file" do
      it "adds a file" do
        tree = Tree.new(name: "/")

        tree.add_file(name: "a", size: 42)

        expect(tree.files.size).to eq 1
        expect(tree.files.first.name).to eq "a"
        expect(tree.files.first.size).to eq 42
      end

      it "updates the size of the directory" do
        tree = Tree.new(name: "/")

        tree.add_file(name: "a", size: 42)
        tree.add_file(name: "b", size: 42)

        expect(tree.size).to eq 84
      end
    end

    describe "#[]" do
      it "returns a directory" do
        tree = Tree.new(name: "/")
        tree.add_directory(name: "a")

        expect(tree["a"].name).to eq "a"
      end
    end
  end
end
