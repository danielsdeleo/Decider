# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

class VectorizeTestHarness
  include Vectorize
end

describe Vectorize do
  
  before do
    @vectorizer = VectorizeTestHarness.new
  end
  
  it "should create a dictionary hash of 'token' => count" do
    klass_a = mock("class A")
    klass_b = mock("class B")
    @vectorizer.stub!(:sorted_classes).and_return([klass_a, klass_b])
    klass_a.stub!(:tokens).and_return(["token1", "token2"])
    klass_b.stub!(:tokens).and_return(["token3"])
    @vectorizer.token_indices.should == {"token1" => 0, "token2" => 1, "token3" => 2}
  end
  
  context "converting documents to vectors" do
    
    before do
      @vectorizer.stub!(:token_indices).and_return({"token1" => 0, "token2" => 1, "token3" => 2})
      @doc = mock("document")
      @doc.stub!(:tokens).and_return(["token1","token3", "token1", "token1"])
      @vectorizer.stub!(:new_document).and_return(@doc)
    end
    
    it "should convert a document to a binary vector" do
      @vectorizer.binary_vector("token1 token3 token1 token1").should == [1,0,1]
    end
    
    it "should convert a document to a proportional frequency vector" do
      @vectorizer.proportional_vector("token1 token3 token1 token1").should == [0.75, 0, 0.25]
    end
    
  end
  
  context "comparing vectors" do
    
    it "should compute the euclidean coefficient" do
      @vectorizer.euclidean_coefficient([1,0,1], [0,0,1]).should == 0.5
      @vectorizer.euclidean_coefficient([1, 0], [1, 0]).should == 1.0
    end
    
    it "should compute the pearson coefficient" do
      @vectorizer.pearson_coefficient([1.0, 1.0],[1.0,1.0]).should be_close 1.0, 0.0000001
      @vectorizer.pearson_coefficient([1,0,1,1], [1,0,1,1]).should be_close 1.0, 0.0000001
      @vectorizer.pearson_coefficient([1,1], [-1,-1]).should == -1.0
      @vectorizer.pearson_coefficient([1,1,1], [0,0,0]).should == 1.0
    end
    
  end
  
end
