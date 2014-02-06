require "csv"
require "rspec/core/formatters/base_formatter"

module RspecLogFormatter
  class Formatter < RSpec::Core::Formatters::BaseFormatter
    FILENAME = "rspec.history"
    TIME_LOG_FILENAME = "rspec.times"

    def initialize(*args)
      super
      @start_time = Time.now
    end

    def self.analyze(filepath)
      Analysis::Analyzer.new.analyze(filepath)
    end

    def dump_summary(_duration, _example_count, _failure_count, _pending_count)
      suite_end_time = Time.now

      File.open(FILENAME, "a") do |f|
        (examples - failed_examples).each do |example|
          record("passed", example, f, suite_end_time)
        end
        failed_examples.each do |example|
          record("failed", example, f, suite_end_time, example.exception)
        end
      end

      File.open(TIME_LOG_FILENAME, "a") do |f|
        f.puts [ENV["BUILD_NUMBER"], suite_end_time, examples.count, elapsed_time].to_csv(col_sep: "\t")
      end
    end

    private

    def record(outcome, example, stream, time, exception=nil)
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

      stream.puts example_data.to_csv(col_sep: "\t")
    end

    def elapsed_time
      Time.now - @start_time
    end
  end
end
