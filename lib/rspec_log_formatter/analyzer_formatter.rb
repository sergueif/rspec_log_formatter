require "csv"
require "rspec/core/formatters/base_formatter"

module RspecLogFormatter
  class AnalyzerFormatter < RSpec::Core::Formatters::BaseFormatter
    FILENAME = "rspec.history"

    RSpec.configure { |c| c.add_setting :num_days_to_analyze }

    def initialize(*args)
      super
    end

    def dump_summary(_,_,_,_)
      if recent_cutoff_line.nil?
        display_full_analysis
      else
        display_partial_analysis(recent_cutoff_line)
      end
    end

    def recent_cutoff_line
      @recent_cutoff_line ||= begin
        if num_days_to_analyze
          cutoff_date = (last_day_to_analyze - num_days_to_analyze).to_s
          File.readlines(FILENAME).index { |x| x.include? cutoff_date }
        end
      end
    end

    def display_full_analysis
      display_analysis_using_file(FILENAME)
    end

    def display_partial_analysis(cutoff_line)
      Tempfile.open(FILENAME + ".partial") do |file|
        `sed "1,#{cutoff_line}d" #{FILENAME} > #{file.path}`
        display_analysis_using_file(file.path)
      end
    end

    private

    def display_analysis_using_file(file_path)
      output.puts RspecLogFormatter::Analysis::PrettyPrinter.new(
        RspecLogFormatter::Analysis::Analyzer.new.analyze(file_path)
      )
    end

    def num_days_to_analyze
      RSpec.configuration.num_days_to_analyze
    end

    def last_day_to_analyze
      Date.today
    end
  end
end
