require 'spec_helper'

describe RspecLogFormatter::PerformanceAnalyzer do
  it "produces a csv of run durations" do
    filepath = File.expand_path("../../../fixtures/test_slowing_down_over_time.history", __FILE__)

    results = RspecLogFormatter::PerformanceAnalyzer.new(filepath).analyze("desc1")
    results.should == [name: 'desc1', data: {
      "2014-01-21 16:00:00 -0800" => 1.0,
      "2014-01-22 16:00:00 -0800" => 2.0,
      "2014-01-24 16:00:00 -0800" => 3.0,
      "2014-01-29 16:00:00 -0800" => 4.0,
      "2014-01-30 16:00:00 -0800" => 5.0,
    }]
  end

  it 'takes multiple test descriptions and gathers data for each' do
    filepath = File.expand_path("../../../fixtures/test_slowing_down_over_time.history", __FILE__)

    results = RspecLogFormatter::PerformanceAnalyzer.new(filepath).analyze(['desc2', 'desc1'])
    results.should == [{name: 'desc1', data: {
        "2014-01-21 16:00:00 -0800" => 1.0,
        "2014-01-22 16:00:00 -0800" => 2.0,
        "2014-01-24 16:00:00 -0800" => 3.0,
        "2014-01-29 16:00:00 -0800" => 4.0,
        "2014-01-30 16:00:00 -0800" => 5.0,
      }},
      {name: "desc2", data: {
        "2014-01-29 16:00:00 -0800" => 4.0,
        "2014-01-30 16:00:00 -0800" => 5.0,
      }}]
  end
end
