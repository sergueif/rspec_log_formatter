require 'spec_helper'

describe RspecLogFormatter::Formatter do

  def make_example(count, opts={})
    double({
      full_description: "description_#{count}",
      file_path: "path_#{count}"
    }.merge(opts))
  end

  def formatter_for_build(build, opts={})
    RspecLogFormatter::Formatter.new({clock: double(now: Time.at(0)), build_number: build}.merge(opts))
  end

  it "can truncate the log file" do
    the_example = make_example(1, limit_history: 2)
    formatter = formatter_for_build(nil)
    formatter.example_started(the_example)
    formatter.example_passed(the_example)
    formatter.dump_summary(1,2,3,4)

    formatter = formatter_for_build(2, limit_history: 2)
    formatter.example_started(the_example)
    formatter.example_passed(the_example)
    formatter.dump_summary(1,2,3,4)

    File.open(RspecLogFormatter::Formatter::FILENAME, 'r').read.should == <<HEREDOC
	1969-12-31 16:00:00 -0800	passed	description_1	path_1			0.0
2	1969-12-31 16:00:00 -0800	passed	description_1	path_1			0.0
HEREDOC

    formatter = formatter_for_build(3, limit_history: 2)
    formatter.example_started(the_example)
    formatter.example_passed(the_example)
    formatter.dump_summary(1,2,3,4)

    formatter = formatter_for_build(4, limit_history: 2)
    formatter.example_started(the_example)
    formatter.example_passed(the_example)
    formatter.dump_summary(1,2,3,4)

    File.open(RspecLogFormatter::Formatter::FILENAME, 'r').read.should == <<HEREDOC
3	1969-12-31 16:00:00 -0800	passed	description_1	path_1			0.0
4	1969-12-31 16:00:00 -0800	passed	description_1	path_1			0.0
HEREDOC
  end

  class FakeClock
    def initialize(now)
      self.now = now
    end
    attr_accessor :now
  end

  it "works" do
    failed_example = make_example(1, exception: Exception.new("Error"))
    passed_example = make_example(2, exception: nil)
    time = Time.parse("2014-02-06 16:01:10")
    clock = FakeClock.new(time)
    formatter = RspecLogFormatter::Formatter.new(clock: clock)
    formatter.example_started(failed_example)
    clock.now = time + 5
    formatter.example_failed(failed_example)

    formatter.example_started(passed_example)
    clock.now = time + 8
    formatter.example_passed(passed_example)
    formatter.dump_summary(1,2,3,4)
    File.open('rspec.history'). readlines.should == [
      "\t2014-02-06 16:01:15 -0800\tfailed\tdescription_1\tpath_1\tError\tException\t5.0\n",
      "\t2014-02-06 16:01:18 -0800\tpassed\tdescription_2\tpath_2\t\t\t3.0\n",
    ]
  end
end
