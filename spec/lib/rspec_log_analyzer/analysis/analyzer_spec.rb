require "spec_helper"
require 'tempfile'

describe RspecLogFormatter::Analysis::Analyzer do
  it "sorts the parsed results by failure fraction" do
    filepath = File.expand_path("../../../../fixtures/varying_flakiness.history", __FILE__)
    history_provider = RspecLogFormatter::HistoryManager.new(filepath)
    described_class.new(history_provider).analyze.map{|r| r[:fraction] }.should == [
      0.75, 2.0/3.0, 0.50
    ]
    described_class.new(history_provider, max_reruns: 0).analyze.map{|r| r[:cost] }.should == [6.0, 5.333333333333332, 4.0]
    described_class.new(history_provider, max_reruns: 1).analyze.map{|r| r[:cost] }.should == [7.5, 7.111111111111111, 6.0]
    described_class.new(history_provider, max_reruns: 2).analyze.map{|r| r[:cost] }.should == [10.875, 10.666666666666668, 9.0]
  end

  it "works" do
    filepath = File.expand_path("../../../../fixtures/fail_history_analyzer.rspec.history", __FILE__)
    described_class.new(RspecLogFormatter::HistoryManager.new(filepath)).analyze.first.should == {
      description: "description0",
      fraction: 0.8571428571428571,
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

  it "works for a test that only passes" do
    result = double(description: 'desc', build_number: 1, failure?: false, success?: true, time: Time.at(0))
    history_provider = double(builds: [1], results: [result])
    described_class.new(history_provider, max_reruns: 3).analyze.should be_empty
  end

  it "works for a test that only fails" do
    result = double(description: 'desc', build_number: 1, failure?: true, success?: false, time: Time.at(0))
    history_provider = double(builds: [1], results: [result])
    described_class.new(history_provider, max_reruns: 3).analyze.should be_empty
  end

  it "can analyze only a window of builds" do
    filepath = File.expand_path("../../../../fixtures/test_was_flaky_then_fixed.history", __FILE__)
    history_provider = RspecLogFormatter::HistoryManager.new(filepath)
    described_class.new(history_provider, builds_to_analyze: 7).analyze.first.should == {
      description: "desc",
      fraction: 0.30,
      failure_messages: ["ec10\n      msg10", "ec10\n      msg10", "ec10\n      msg10"]
    }
    described_class.new(history_provider, builds_to_analyze: 5).analyze.first.should == {
      description: "desc",
      fraction: 0.16666666666666666,
      failure_messages: ["ec10\n      msg10"],
    }
  end
end
