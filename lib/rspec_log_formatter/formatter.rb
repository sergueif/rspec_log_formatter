require "csv"
require "rspec/core/formatters/base_formatter"

module RspecLogFormatter
  class Formatter < RSpec::Core::Formatters::BaseFormatter
    FILENAME = "rspec.history"

    class Config
      def clock=(clock)
        @clock = clock
      end
      def clock
        @clock ||= Time
        @clock
      end
    end
    CONFIG = Config.new

    def initialize(*args)
      super
      @clock = CONFIG.clock
      @start_time = @clock.now
    end

    def self.analyze(filepath)
      Analysis::Analyzer.new.analyze(filepath)
    end

    def example_passed(example)
      record("passed", example, @clock.now)
    end

    def example_failed(example)
      record("failed", example, @clock.now, example.exception)
    end

    private

    def record(outcome, example, time, exception=nil)
      if exception
        exception_data = [
          exception.message.gsub(/\r|\n|\t/, " "),
          exception.class,
        ]
      else
        exception_data = []
      end

      example_data = [
        ENV["BUILD_NUMBER"],
        time,
        outcome,
        example.full_description.to_s.gsub(/\r|\n|\t/, " "),
        example.file_path,
      ] + exception_data

      File.open(FILENAME, "a") do |f|
        f.puts example_data.to_csv(col_sep: "\t")
      end
    end

  end
end
