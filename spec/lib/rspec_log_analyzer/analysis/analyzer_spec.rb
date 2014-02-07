require "spec_helper"
require 'tempfile'

describe RspecLogFormatter::Analysis::Analyzer do
  it "sorts the parsed results by failure percentage" do
    filepath = File.expand_path("../../../../fixtures/varying_flakiness.history", __FILE__)
    described_class.new.analyze(filepath).map{|r| r[:percent] }.should == [
      75.0, 100*2.0/3.0, 50.0
    ]
  end

  it "works" do
    filepath = File.expand_path("../../../../fixtures/fail_history_analyzer.rspec.history", __FILE__)
    described_class.new.analyze(filepath).first.should == {
      description: "description0",
      percent: 85.71428571428571,
      failure_messages: [
        "ec10\n      msg10",
        "ec20\n      msg20",
        "ec30\n      msg30",
        "ec40\n      msg40",
        "ec50\n      msg50",
        "ec60\n      msg60",
      ]
    }
  end


  it "can truncate the log file" do
    filepath = File.expand_path("../../../../fixtures/test_was_flaky_then_fixed.history", __FILE__)
    temp = Tempfile.new('fixture')
    FileUtils.copy(filepath, temp.path)
    described_class.new.truncate(temp.path, keep_builds: 3)
    File.open(temp.path, 'r').read.should == <<HEREDOC
5	2014-01-21 16:08:25 -0800	passed	desc	./spec/m1k1_spec.rb
6	2014-01-21 16:08:25 -0800	passed	desc	./spec/m1k1_spec.rb
7	2014-01-21 16:08:25 -0800	passed	desc	./spec/m1k1_spec.rb
HEREDOC
  end

  it "can analyze only a window of builds" do
    filepath = File.expand_path("../../../../fixtures/test_was_flaky_then_fixed.history", __FILE__)
    subject.analyze(filepath, last_builds: 7).first.should == {
      description: "desc",
      percent: 30.0,
      failure_messages: ["ec10\n      msg10", "ec10\n      msg10", "ec10\n      msg10"]
    }
    subject.analyze(filepath, last_builds: 4).first.should == {
      description: "desc",
      percent: 0.0,
      failure_messages: []
    }

  end
end
