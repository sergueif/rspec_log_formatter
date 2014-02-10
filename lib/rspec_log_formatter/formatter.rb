require "csv"
require "rspec/core/formatters/base_formatter"

module RspecLogFormatter
  class Formatter < RSpec::Core::Formatters::BaseFormatter
    FILENAME = "rspec.history"

    def initialize(output, opts={})
      @clock = opts[:clock] || Time
      @build_number = opts[:build_number] || ENV["BUILD_NUMBER"]
      @keep_builds = opts[:keep_builds]
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
      return unless @keep_builds
      RspecLogFormatter::Analysis::Analyzer.new.truncate(FILENAME, keep_builds: @keep_builds)
    end

    private

    attr_reader :clock

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
        @build_number,
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
