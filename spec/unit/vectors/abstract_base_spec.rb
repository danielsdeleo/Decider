# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"

describe Vectors::AbstractBase do
  
  before do
    @base = Vectors::AbstractBase.new
  end
  
  it "should have method stubs for :difference_coefficient, :average" do
    lambda {@base.closeness(nil)}.should raise_error Decider::NotImplementedError
    lambda {@base.average(nil)}.should raise_error Decider::NotImplementedError
  end
  
end
