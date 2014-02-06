module RspecLogFormatter
  module Analysis
    class Score
      def initialize(desc)
        @description = desc
        @runs = 0
        @failures = 0
        @failure_messages = []
      end

      def percent
        100 * @failures.to_f/@runs
      end

      def <=>(other)
        other.percent <=> percent
      end

      def as_hash
        {
          description: @description,
          percent: percent,
          failure_messages: failure_messages,
        }
      end
      attr_accessor :runs, :failures, :failure_messages
    end
  end
end
