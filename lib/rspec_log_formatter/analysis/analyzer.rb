
module RspecLogFormatter
  module Analysis
    class Analyzer

      def initialize(options={})
        @builds_to_analyze = options[:builds_to_analyze]
        @max_reruns = options[:max_reruns]
        @limit_history = options[:limit_history]
      end

      def analyze(filepath)
        history_manager = HistoryManager.new(filepath)
        build_numbers = history_manager.builds
        results = history_manager.results.reject do |res|
          @builds_to_analyze && !build_numbers.last(@builds_to_analyze).include?(res.build_number.to_i)
        end

        scores = []
        results.group_by(&:description).each do |description, results|
          score = Score.new(description, max_reruns: @max_reruns)

          results.group_by(&:build_number).each do |build_number, results|
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
    end
  end
end
