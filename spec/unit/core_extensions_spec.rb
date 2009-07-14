# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

describe ::Math, "with core extensions" do
  
  it "should compute the variance of a collection" do
    Math.variance([0,0,1,1]).should == 0.25
  end
  
  it "should compute the variance of a sample of a collection" do
    Math.variance([1,1,0,0], :sample=>true).should == (1.0/3.0)
  end
  
  it "should compute the standard deviation of a collection" do
    Math.stddev([1,1,0,0]).should == 0.5
  end
  
  it "should compute the standard deviation of a sample of a collection" do
    Math.stddev([1,1,0,0], :sample => true).should == Math.sqrt(1.0/3.0)
  end
end

describe Hash do
  it "should map values based on the given block" do
    {:a=>1,:b=>2,:c=>3}.map_vals {|v| v ** 2 }.should == {:a=>1,:b=>4,:c=>9}
  end
end