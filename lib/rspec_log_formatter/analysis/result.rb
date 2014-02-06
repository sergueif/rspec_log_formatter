module RspecLogFormatter
  module Analysis
    class Result
      def initialize(build_number, time, outcome, description, spec_path, message=nil, klass=nil)
        @build_number = build_number
        @description = description
        @outcome = outcome
        @spec_path = spec_path
        @message = message
        @klass = klass
      end

      attr_accessor :build_number, :description
      attr_reader :message, :klass

      def failure?
        @outcome == "failed"
      end

      def success?
        @outcome == "passed"
      end
    end
  end
end
