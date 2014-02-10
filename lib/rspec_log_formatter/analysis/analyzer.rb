require 'csv'

module RspecLogFormatter
  module Analysis
    class Analyzer

      def initialize(options={})
        @builds_to_analyze = options[:builds_to_analyze]
        @max_reruns = options[:max_reruns]
        @limit_history = options[:limit_history]
      end

      def analyze(filepath)

        build_numbers, results = result_numbers(filepath)

        scores = []
        results.group_by(&:description).each do |description, results|
          score = Score.new(description, max_reruns: @max_reruns)

          results.group_by(&:build_number).each do |build_number, results|
            next if (@builds_to_analyze && !build_numbers.last(@builds_to_analyze).include?(build_number))
            next if results.all?(&:failure?) #not flaky


            results.each{|r| score.absorb(r) }
            score.runs += results.count
            score.failures += results.count(&:failure?)
            score.failure_messages += results.select(&:failure?).map { |r| "#{r.klass}\n      #{r.message}" }
          end
          scores << score if score.runs > 0
        end

        scores.select(&:flaky?).sort.map(&:as_hash)
      end

      def truncate(filepath)
        build_numbers, results = result_numbers(filepath)
        sio = StringIO.new

        File.open(filepath, 'r').each_line do |line|
          result = parse_line(line)
          next unless build_numbers.last(@limit_history).include? result.build_number
          sio.puts line
        end

        sio.rewind
        File.open(filepath, 'w') do |f|
          f.write sio.read
        end
      end

      private

      def parse_line(line)
        Result.new(*CSV.parse_line(line, col_sep: "\t").first(8))
      end

      def each_result(filepath, &block)
        File.open(filepath, 'r').each_line do |line|
          result = parse_line(line)
          block.call(result)
        end
      end

      def result_numbers(filepath)
        build_numbers = []
        results = []
        each_result(filepath) do |result|
          build_numbers << result.build_number
          results << result
        end
        [build_numbers.uniq.sort_by{|bn| bn.to_i}, results]
      end

    end

  end
end
