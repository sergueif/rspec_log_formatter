module RspecLogFormatter
  module Analysis
    class PrettyPrinter
      def initialize(results)
        @results = results
      end

      def to_s
        results = @results.reject do |result|
          result[:fraction] == 0.0
        end.first(10)

        header = if results.empty?
          "None of the specs were flaky"
        else
          "Top #{results.size} flakiest examples\n"
        end
        header + results.each_with_index.map do |result, i|
          title = "  #{i+1}) #{result[:description]} -- #{(100.0*result[:fraction]).to_i}%#{cost_segment(result)}"
          failure_messages = result[:failure_messages].map { |fm| "    * #{fm}" }.join("\n")
          title + "\n" + failure_messages
        end.join("\n")
      end

      def cost_segment(result)
        " (cost: #{result[:cost].to_i}s)" if result[:cost]
      end
    end
  end
end
