require 'csv'

module RspecLogFormatter
  module Analysis
    class Analyzer
      def analyze(filepath)
        results = File.open(filepath).each_line.map do |line|
          Result.new(*CSV.parse_line(line, col_sep: "\t").first(7))
        end

        scores = []
        results.group_by(&:description).each do |description, results|
          score = Score.new(description)
          results.group_by(&:build_number).each do |_build_number, results|
            next if results.all?(&:failure?)

            score.runs += results.count
            score.failures += results.count(&:failure?)
            score.failure_messages += results.select(&:failure?).map { |r| "#{r.klass}\n      #{r.message}" }
          end
          scores << score if score.runs > 0
        end

        scores.sort.map(&:as_hash)
      end
    end
  end
end
