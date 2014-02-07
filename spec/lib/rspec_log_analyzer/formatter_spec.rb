require 'spec_helper'

describe RspecLogFormatter::Formatter do

  def make_example(opts={})
    @count ||= 0; @count += 1
    double({
      full_description: "description_#{@count}",
      file_path: "path_#{@count}"
    }.merge(opts))
  end

  it "works" do
    failed_example = make_example(exception: Exception.new("Error"))
    passed_example = make_example(exception: nil)
    time = Time.parse("2014-02-06 16:01:10")
    clock = double(now: time)
    RspecLogFormatter::Formatter::CONFIG.clock = clock

    formatter = RspecLogFormatter::Formatter.new(StringIO.new)
    formatter.example_started(failed_example)
    #clock.stub(now: time + 5)
    RspecLogFormatter::Formatter::CONFIG.clock = double(now: time + 5)
    formatter.example_failed(failed_example)

    formatter.example_started(passed_example)
    #clock.stub(:now, time + 8)
    RspecLogFormatter::Formatter::CONFIG.clock = double(now: time + 8)
    formatter.example_passed(passed_example)
    formatter.dump_summary(1,2,3,4)
    File.open('rspec.history').readlines.should == [
      "\t2014-02-06 16:01:15 -0800\tfailed\tdescription_1\tpath_1\tError\tException\t5.0\n",
      "\t2014-02-06 16:01:18 -0800\tpassed\tdescription_2\tpath_2\t\t\t3.0\n",
    ]
  end
end
