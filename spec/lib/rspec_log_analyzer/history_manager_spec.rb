require 'spec_helper'

describe RspecLogFormatter::HistoryManager do
  it "can truncate the log file" do
    filepath = File.expand_path("../../../fixtures/test_was_flaky_then_fixed.history", __FILE__)
    temp = Tempfile.new('fixture')
    FileUtils.copy(filepath, temp.path)
    RspecLogFormatter::HistoryManager.new(temp.path).truncate(3)
    File.open(temp.path, 'r').read.should == <<HEREDOC
5	2014-01-21 16:08:25 -0800	passed	desc	./spec/m1k1_spec.rb
6	2014-01-21 16:08:25 -0800	passed	desc	./spec/m1k1_spec.rb
7	2014-01-21 16:08:25 -0800	passed	desc	./spec/m1k1_spec.rb
HEREDOC
  end
end

