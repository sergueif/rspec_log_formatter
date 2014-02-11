require 'time'

module RspecLogFormatter
  module Analysis
    class Result
      def initialize(build_number, time, outcome, description, spec_path, message=nil, klass=nil,duration=nil)
        @time = Time.parse(time)
        @build_number = (build_number || -1).to_i
        @description = description
        @outcome = outcome
        @spec_path = spec_path
        @message = message
        @klass = klass
        @duration = duration.to_f
      end

      attr_accessor :build_number, :description, :duration
      attr_reader :message, :klass, :time

      def failure?
        @outcome == "failed"
      end

      def success?
        @outcome == "passed"
      end
    end
  end
end
