module RspecLogFormatter
  module Analysis
    class Score
      def initialize(desc, opts={})
        @description = desc
        @runs = 0
        @failures = 0
        @failure_messages = []
        @last_fail_time = Time.at(0)
        @last_pass_time = Time.at(0)
        @max_reruns = opts[:max_reruns]
      end

      def fraction
        @failures.to_f/@runs
      end

      def cost
        sum = 0.0
        0.upto(max_reruns) do |i|
          sum += (fraction**i)*(1.0-fraction)*(i*@fail_duration + @pass_duration)
        end
        sum + (fraction**(max_reruns+1.0))*@fail_duration
      end

      def <=>(other)
        if max_reruns
          other.cost <=> cost
        else
          other.fraction <=> fraction
        end
      end

      def flaky?
        fraction > 0.0
      end

      def absorb(result)
        if result.failure? && result.time > @last_fail_time
          @last_fail_time = result.time
          @fail_duration = result.duration
        elsif result.success? && result.time > @last_pass_time
          @last_pass_time = result.time
          @pass_duration = result.duration
        end
      end

      def as_hash
        h = {
          description: @description,
          fraction: fraction,
          failure_messages: failure_messages,
        }
        if max_reruns
          h.merge!({cost: cost})
        end
        h
      end
      attr_accessor :runs, :failures, :failure_messages

      private
      attr_reader :max_reruns
    end
  end
end
