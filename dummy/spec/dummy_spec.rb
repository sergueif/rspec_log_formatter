require 'spec_helper'

describe "Math" do
  it "flakes" do
    sleep 2 #2 seconds to pass
    if File.exists?('rspec.failures')
    else
      sleep 2 #4 seconds to fail
      fail
    end
  end

  it "works 2" do
    2.should == 2
  end
end
