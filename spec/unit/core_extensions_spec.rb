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
  
  it "should sum the elements in an array" do
    Math.sum_floats([1,1.5, -0.25]).should == 2.25
  end
end

describe Hash do
  it "should map values based on the given block" do
    {:a=>1,:b=>2,:c=>3}.map_vals {|v| v ** 2 }.should == {:a=>1,:b=>4,:c=>9}
  end
end

module CoreExtensionsSpec
  module NestedConst
    module NestedDeeper
      
    end
  end
end

describe String do
  it "should convert to a constant" do
    "core_extensions_spec/nested_const".to_const.should == CoreExtensionsSpec::NestedConst
    "core_extensions_spec/nested_const/nested_deeper".to_const.should == CoreExtensionsSpec::NestedConst::NestedDeeper
    "module".to_const.should == Module
  end
end

describe Symbol do
  it "should define <=> as self.to_s <=> other.to_s" do
    [:a, :x, :n].sort.should == [:a, :n, :x]
  end
end

describe Array do
  it "should compute the dot product of itself and another equal-sized array" do
    [1,3,5].dot([2,7,3]).should == (1 * 2) + (3 * 7) + (5 * 3)
  end
  
  it "should compute dot products for unequal sized arrays" do
    [3,5].dot([2,7,11]).should == (6 + 35)
    [2,7,11,13,17,19,23].dot([3,5]).should == (6 + 35)
  end
end