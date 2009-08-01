# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"

describe Vectors::Binary do
  
  it "should create a prototype vector from a token indices hash" do
    token_indices = {:some => 0, :tokens => 1, :in_a => 2, :hash => 3}
    v = Vectors::Binary.prototype(token_indices)
    v.to_a.should == Array.new(4, 0)
    v.index_of.should == token_indices
  end
  
  it "should define #new on the prototype" do
    v = Vectors::Binary.prototype({:a_token => 0})
    v.should respond_to(:new)
  end
  
  context "after the prototype is created" do
    
    before do
      @token_indices = {:lolz => 0, :catz => 1, :in_ur_fridge => 2, :eatin_ur_foodz => 3}
      @prototype = Vectors::Binary.prototype(@token_indices)
    end
    
    it "should create a vector from a document" do
      doc = mock("lolz document")
      doc.stub!(:tokens).and_return([:lolz, :in_ur_fridge, :lolz])
      new_v = @prototype.new(doc)
      new_v.to_a.should == [1, 0, 1, 0]
    end
    
    context "when comparing and averaging vectors" do

      before do
        vector_1110_doc = mock("lolz catz in_ur_fridge")
        vector_1110_doc.stub!(:tokens).and_return([:lolz, :catz, :in_ur_fridge])
        @lolz_catz = @prototype.new(vector_1110_doc)
        vector_0111_doc = mock("catz in_ur_fridge eatin_ur_foodz")
        vector_0111_doc.stub!(:tokens).and_return([:catz, :in_ur_fridge, :eatin_ur_foodz])
        @eatin_ur_foodz = @prototype.new(vector_0111_doc)
      end
      
      # http://en.wikipedia.org/wiki/Jaccard_index
      # m_11 = 2; m_01 = 1; m_10 = 1;
      # (m_11) / (m_11 + m_01 + m_10) #=> 0.5
      it "should give the tanimoto coefficient for two vectors" do
        @lolz_catz.closeness(@eatin_ur_foodz).should == 0.5
      end

    end
    
  end
  
  
end
