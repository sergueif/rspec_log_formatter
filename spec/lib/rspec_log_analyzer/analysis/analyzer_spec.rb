require "spec_helper"

describe RspecLogFormatter::Analysis::Analyzer do
  it "parses an rspec.history file and returns parsed results"
  it "sorts the parsed results by failure percentage"
  it "organizes results by spec description"
  it "needs more specs"

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
