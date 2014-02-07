require 'csv'

module RspecLogFormatter
  module Analysis
    class Analyzer
      def analyze(filepath, options = {})
        window = options[:last_builds]

        build_numbers, results = result_numbers(filepath, options = {})

        scores = []
        results.group_by(&:description).each do |description, results|
          score = Score.new(description)

          results.group_by(&:build_number).each do |build_number, results|
            next if (window && !build_numbers.last(window).include?(build_number))
            next if results.all?(&:failure?) #not flaky


            score.runs += results.count
            score.failures += results.count(&:failure?)
            score.failure_messages += results.select(&:failure?).map { |r| "#{r.klass}\n      #{r.message}" }
          end
          scores << score if score.runs > 0
        end

        scores.sort.map(&:as_hash)
      end

      def truncate(filepath, opts = {})
        builds = opts.fetch(:keep_builds)
        build_numbers, results = result_numbers(filepath, options = {})
        sio = StringIO.new

        File.open(filepath, 'r').each_line do |line|
          result = parse_line(line)
          next unless build_numbers.last(builds).include? result.build_number
          sio.puts line
        end

        sio.rewind
        File.open(filepath, 'w') do |f|
          f.write sio.read
        end
      end

      private

      def parse_line(line)
        Result.new(*CSV.parse_line(line, col_sep: "\t").first(7))
      end

      def each_result(filepath, &block)
        File.open(filepath, 'r').each_line do |line|
          result = parse_line(line)
          block.call(result)
        end
      end

      def result_numbers(filepath, options = {})
        build_numbers = []
        results = []
        each_result(filepath) do |result|
          build_numbers << result.build_number
          results << result
        end
        [build_numbers.uniq!.sort!, results]
      end

    end

  end
end
