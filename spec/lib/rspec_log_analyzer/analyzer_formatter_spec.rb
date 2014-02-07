require 'spec_helper'

describe RspecLogFormatter::Formatter do


  it "works" do
    filepath = File.expand_path("../../../fixtures/varying_flakiness.history", __FILE__)
    FileUtils.cp(filepath, 'rspec.history')
    out = StringIO.new
    formatter = RspecLogFormatter::AnalyzerFormatter.new(out)
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
end
