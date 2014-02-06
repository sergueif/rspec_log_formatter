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
end
