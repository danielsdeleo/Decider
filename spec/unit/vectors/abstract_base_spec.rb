# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"

class ExampleSubclass < Vectors::AbstractBase
  attr_reader :was_duplicated
  
  def convert_document(whatever)
    nil
  end
  
  def duplicated
    @was_duplicated = true
  end
  
end

describe Vectors::AbstractBase do
  
  before do
    @base = Vectors::AbstractBase.new({})
  end
  
  it "should have method stubs for :difference_coefficient, :average" do
    lambda {@base.closeness(nil)}.should raise_error Decider::NotImplementedError
    lambda {@base.average(nil)}.should raise_error Decider::NotImplementedError
  end
  
  it "should create a prototype vector from a token index hash" do
    token_indices = {:some => 0, :tokens => 1, :in_a => 2, :hash => 3}
    v = Vectors::AbstractBase.prototype(token_indices)
    v.index_of.should == token_indices
  end
  
  it "should define #new on the prototype vector" do
    v = Vectors::AbstractBase.prototype({:a_token => 0})
    v.should respond_to(:new)
  end
  
  context "creating new vectors from the prototype" do
    
    before do
      @token_indices = {:lolz => 0, :catz => 1, :in_ur_fridge => 2, :eatin_ur_foodz => 3}
      @prototype = ExampleSubclass.prototype(@token_indices)
    end
    
    it "should create a vector from a document" do
      doc = mock("lolz document")
      doc.stub!(:tokens).and_return([:lolz, :in_ur_fridge, :lolz])
      new_v = @prototype.new(doc)
      new_v.should be_an_instance_of ExampleSubclass
      new_v.should_not equal(@prototype)
      new_v.was_duplicated.should be_true
    end
    
  end
  
end
