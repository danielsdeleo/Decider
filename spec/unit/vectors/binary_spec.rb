# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"
require File.dirname(__FILE__) + "/binary_vector_behavior"

describe Vectors::Binary do
  
  before do
    @vector_class = Vectors::Binary
  end
  
  it_should_behave_like "a binary vector"
  
  it "should create a new vector from an array" do
    v = Vectors::Binary.from_array([1,0,0,1])
    v.to_a.should == [1,0,0,1]
  end
  
  it "should give the correct distance between two vectors" do
    v1, v2 = Vectors::Binary.from_array([1,1,0,0]), Vectors::Binary.from_array([0,0,1,1])
    v1.distance(v2).should == 4
    v1, v2 = Vectors::Binary.from_array([0,1,1,0]), Vectors::Binary.from_array([1,1,1,0])
    v1.distance(v2).should == 1
  end
  
end
