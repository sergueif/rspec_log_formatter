require "csv"
require "rspec/core/formatters/base_formatter"

module RspecLogFormatter
  class Formatter
    FILENAME = "rspec.history"

    class Factory
      def initialize(options={})
        @options = options
      end

      def build
        RspecLogFormatter::Formatter.new({
          clock: Time,
          build_number: ENV["BUILD_NUMBER"],
          limit_history: nil
        }.merge(@options))
      end
    end

    def initialize(opts={})
      @clock = opts[:clock]
      @build_number = opts[:build_number]
      @limit_history = opts[:limit_history]
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
      return unless @limit_history
      RspecLogFormatter::HistoryManager.new(FILENAME).truncate(@limit_history)
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
