# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"
require File.dirname(__FILE__) + "/binary_vector_behavior"

describe Vectors::SparseBinary do
  
  before do
    @vector_class = Vectors::SparseBinary
  end
  
  it_should_behave_like "a binary vector"
  
  context "getting an extra workout" do
    
    before do
      @token_index_hash = {}
      1000.times { |i| @token_index_hash[i] = i }
      @vector_a = @vector_class.new(@token_index_hash)
      @vector_a_clone = @vector_class.new(@token_index_hash)
      vector_a_items = mock("vector a items")
      vector_a_items.stub!(:tokens).and_return([5,10,15,20,25,30,35,40,45,50,55,60,65,70,75])
      @vector_a.convert_document(vector_a_items) # 15 total
      @vector_a_clone.convert_document(vector_a_items)
      @vector_b = @vector_class.new(@token_index_hash)
      vector_b_items = mock("vector b items")
      vector_b_items.stub!(:tokens).and_return([23,45])
      @vector_b.convert_document(vector_b_items)
    end
  
    it "should determine the correct distance" do
      @vector_a.distance(@vector_b).should == 15
    end
    
    it "should give its vector's size (and cache it)" do
      @vector_a.vector_size.should == 15
      @vector_b.vector_size.should == 2
      @vector_a.send(:instance_variable_get, :@vector_size).should == 15
    end
    
  end
end
