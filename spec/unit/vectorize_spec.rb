# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

class VectorizeTestHarness
  include Vectorize
end

describe Vectorize do
  
  before(:each) do
    @vectorizer = VectorizeTestHarness.new
  end
  
  context "constructing binary vectors" do
    
    it "should create a dictionary hash of 'token' => count" do
      klass_a = mock("class A")
      klass_b = mock("class B")
      @vectorizer.stub!(:sorted_classes).and_return([klass_a, klass_b])
      klass_a.stub!(:tokens).and_return(["token1", "token2"])
      klass_b.stub!(:tokens).and_return(["token3"])
      @vectorizer.token_indices.should == {"token1" => 0, "token2" => 1, "token3" => 2}
    end
    
    it "should convert a document to a binary vector" do
      @vectorizer.stub!(:token_indices).and_return({"token1" => 0, "token2" => 1, "token3" => 2})
      doc = mock("document")
      doc.stub!(:tokens).and_return(["token1", "token3"])
      @vectorizer.stub!(:new_document).and_return(doc)
      @vectorizer.binary_vector("token1 token3").should == [1,0,1]
    end
    
  end
  
end
