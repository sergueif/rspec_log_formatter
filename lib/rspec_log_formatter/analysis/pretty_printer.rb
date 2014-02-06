module RspecLogFormatter
  module Analysis
    class PrettyPrinter
      def initialize(results)
        @results = results
      end

      def to_s
        results = @results.first(10)
        header = "Top #{results.count} flakiest examples\n"
        header + results.each_with_index.map do |result, i|
          title = "  #{i+1}) #{result[:description]} -- #{result[:percent]}%"
          failure_messages = result[:failure_messages].map { |fm| "    * #{fm}" }.join("\n")
          title + "\n" + failure_messages
        end.join("\n")
      end
    end
  end
end
