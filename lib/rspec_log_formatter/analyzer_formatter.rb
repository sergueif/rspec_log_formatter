require "csv"
require "rspec/core/formatters/base_formatter"

module RspecLogFormatter
  class AnalyzerFormatter
    FILENAME = "rspec.history"

    class Factory
      def initialize(options={})
        @options = options
      end

      def build(output)
        RspecLogFormatter::AnalyzerFormatter.new(output, {
        }.merge(@options))
      end
    end

    def initialize(output, options={})
      @output = output
      @options = options
    end

    def dump_summary(_,_,_,_)
      @output.puts RspecLogFormatter::Analysis::PrettyPrinter.new(
        RspecLogFormatter::Analysis::Analyzer.new(@options).analyze(FILENAME)
      )
    end

  end
end
