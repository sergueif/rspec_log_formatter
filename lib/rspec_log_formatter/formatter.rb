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
      attr_accessor :keep_builds
    end
    CONFIG = Config.new

    def initialize(*args)
      super
    end

    def example_started(example)
      @clock_start = clock.now
    end

    def example_passed(example)
      record("passed", example, clock.now, clock.now - @clock_start)
    end

    def example_failed(example)
      record("failed", example, clock.now, clock.now - @clock_start, example.exception)
    end

    def dump_summary(_,_,_,_)
      RspecLogFormatter::Analysis::Analyzer.new.truncate(FILENAME, keep_builds: CONFIG.keep_builds)
    end

    private

    def clock
      CONFIG.clock
    end

    def record(outcome, example, time, duration, exception=nil)
      if exception
        exception_data = [
          exception.message.gsub(/\r|\n|\t/, " "),
          exception.class,
        ]
      else
        exception_data = [nil,nil]
      end

      example_data = [
        ENV["BUILD_NUMBER"],
        time,
        outcome,
        example.full_description.to_s.gsub(/\r|\n|\t/, " "),
        example.file_path,
      ] + exception_data + [duration]

      File.open(FILENAME, "a") do |f|
        f.puts example_data.to_csv(col_sep: "\t")
      end
    end

  end
end
