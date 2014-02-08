require 'spec_helper'

describe RspecLogFormatter::AnalyzerFormatter do
  let(:out) { StringIO.new }
  subject(:formatter) { described_class.new(out) }

  it "works" do
    filepath = File.expand_path("../../../fixtures/varying_flakiness.history", __FILE__)
    FileUtils.cp(filepath, 'rspec.history')
    formatter.dump_summary(1,2,3,4)
    out.rewind
    out.read.should == <<HEREDOC
Top 3 flakiest examples
  1) desc3 -- 75.0%
    * ec10
      msg10
    * ec10
      msg10
    * ec10
      msg10
  2) desc2 -- 66.66666666666667%
    * ec10
      msg10
    * ec10
      msg10
  3) desc1 -- 50.0%
    * ec10
      msg10
HEREDOC
  end

  describe "varying the length of history to analyze" do
    let(:file_path) { File.expand_path("../../../fixtures/varying_flakiness_over_days.history", __FILE__) }
    before { FileUtils.cp(file_path, "rspec.history") }

    context "when no number of days is specified" do
      it "displays analysis of the full history" do
        formatter.dump_summary(1,2,3,4)
        out.rewind
        out.read.should == <<HEREDOC
Top 3 flakiest examples
  1) desc3 -- 75.0%
    * ec10
      msg10
    * ec10
      msg10
    * ec10
      msg10
  2) desc2 -- 66.66666666666667%
    * ec10
      msg10
    * ec10
      msg10
  3) desc1 -- 66.66666666666667%
    * ec10
      msg10
    * ec10
      msg10
HEREDOC
      end
    end

    context "when the number of days is specified" do
      # Stubbing object under test :(, but avoids setting RSpec configuration in test
      before { subject.stub(num_days_to_analyze: num_days_to_analyze) }

      # Stubbing Date :(, but can't pass date in as dependency since class must
      #   conform to Formatter interface
      before { Date.stub(today: Date.parse("2014-01-24 16:08:25")) }

      context "when there was a test run that number of days ago" do
        let(:num_days_to_analyze) { 2 }

        it "displays analysis of the history from that many days ago" do
          formatter.dump_summary(1,2,3,4)
          out.rewind
          out.read.should == <<HEREDOC
Top 3 flakiest examples
  1) desc3 -- 66.66666666666667%
    * ec10
      msg10
    * ec10
      msg10
  2) desc2 -- 50.0%
    * ec10
      msg10
  3) desc1 -- 50.0%
    * ec10
      msg10
HEREDOC
        end
      end

      context "when the oldest test run happened more recently than that many days ago" do
        let(:num_days_to_analyze) { 4 }

        it "displays analysis of the full history" do
          formatter.dump_summary(1,2,3,4)
          out.rewind
          out.read.should == <<HEREDOC
Top 3 flakiest examples
  1) desc3 -- 75.0%
    * ec10
      msg10
    * ec10
      msg10
    * ec10
      msg10
  2) desc2 -- 66.66666666666667%
    * ec10
      msg10
    * ec10
      msg10
  3) desc1 -- 66.66666666666667%
    * ec10
      msg10
    * ec10
      msg10
HEREDOC
        end
      end

      context "when the most recent test run happened more than that many days ago" do
        pending "displays message that there are no recent tests to analyze"
      end

      context "when the specified number of days is invalid" do
        pending "displays message warning that the specified number of days is invalid"
      end
    end
  end
end
