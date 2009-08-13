# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"

describe Vectors::BinaryRecommendation do
  
  before do
    @vector_class = Vectors::BinaryRecommendation
  end
  
  before do
    @token_index_hash = {}
    1000.times { |i| @token_index_hash[i] = i }
    @vector_a = @vector_class.new(@token_index_hash)
    vector_a_items = mock("vector a items")
    vector_a_items.stub!(:tokens).and_return([5,10,15,20,25,30,35,40,45,50,55,60,65,70,75])
    @vector_a.convert_document(vector_a_items) # 15 total
    @vector_b = @vector_class.new(@token_index_hash)
    vector_b_items = mock("vector b items")
    vector_b_items.stub!(:tokens).and_return([23,45])
    @vector_b.convert_document(vector_b_items)
  end
  
  it "gives the distance between A and B as the number of elements in A that are not in B" do
    @vector_a.distance(@vector_b).should == 14
    @vector_b.distance(@vector_a).should == 1
  end
  
end
