require "csv"
require "rspec/core/formatters/base_formatter"

module RspecLogFormatter
  class AnalyzerFormatter < RSpec::Core::Formatters::BaseFormatter
    FILENAME = "rspec.history"

    def initialize(*args)
      super
    end


    def dump_summary(_,_,_,_)
      output.puts RspecLogFormatter::Analysis::PrettyPrinter.new(
        RspecLogFormatter::Analysis::Analyzer.new.analyze(FILENAME)
      )
    end

  end
end
