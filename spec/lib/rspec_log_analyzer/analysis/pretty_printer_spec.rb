require 'spec_helper'

describe RspecLogFormatter::Analysis::PrettyPrinter do
  it "pretty prints the results of an analysis" do
    results = [{
      description: "I fail a lot.",
      percent: 99,
      failure_messages: ["I'm a total failure."]
    },{
      description: "I fail often.",
      percent: 70,
      failure_messages: ["I am a failure message.", "I'm another failure message."]
    }]

    described_class.new(results).to_s.should == <<-TEXT.strip
Top 2 flakiest examples
  1) I fail a lot. -- 99%
    * I'm a total failure.
  2) I fail often. -- 70%
    * I am a failure message.
    * I'm another failure message.
    TEXT
  end

  context "when there are more than 10 results" do
    it "only prints the top 10" do
      results = (1..20).map do |i|
        {description: "hi#{i}", percent: 1, failure_messages: ["bye#{i}"]}
      end

      described_class.new(results).to_s.should == <<-TEXT.strip
Top 10 flakiest examples
  1) hi1 -- 1%
    * bye1
  2) hi2 -- 1%
    * bye2
  3) hi3 -- 1%
    * bye3
  4) hi4 -- 1%
    * bye4
  5) hi5 -- 1%
    * bye5
  6) hi6 -- 1%
    * bye6
  7) hi7 -- 1%
    * bye7
  8) hi8 -- 1%
    * bye8
  9) hi9 -- 1%
    * bye9
  10) hi10 -- 1%
    * bye10
      TEXT
    end
  end
end
