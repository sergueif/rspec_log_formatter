require 'csv'
require 'set'

module RspecLogFormatter
  class HistoryManager
    def initialize(filepath)
      @filepath = filepath
    end

    def truncate(number_of_builds)
      builds = results.map{|r| r.build_number.to_i}.reduce(SortedSet.new, &:<<).to_a.last(number_of_builds)
      sio = StringIO.new

      lines.each do |line|
        sio.puts line if builds.include? (parse(line).build_number.to_i)
      end

      sio.rewind

      File.open(@filepath, 'w') do |f|
        f.write sio.read
      end
    end

    private

    def parse(line)
      RspecLogFormatter::Analysis::Result.new(*CSV.parse_line(line, col_sep: "\t").first(8))
    end

    def results
      lines.map do |line|
        parse(line)
      end
    end

    def lines
      File.open(@filepath, 'r').lazy
    end
  end
end
