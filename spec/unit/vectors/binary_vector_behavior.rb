shared_examples_for "a binary vector" do
  
  before do
    @token_indices = {:lolz => 0, :catz => 1, :in_ur_fridge => 2, :eatin_ur => 3, :foodz => 4}
    @prototype = @vector_class.prototype(@token_indices)
  end
  
  it "should create a vector from a document" do
    doc = mock("lolz document")
    doc.stub!(:tokens).and_return([:lolz, :in_ur_fridge, :lolz])
    new_v = @prototype.new(doc)
    new_v.to_a.should == [1, 0, 1, 0, 0]
  end
  
  context "when comparing and averaging vectors" do

    before do
      vector_11101_doc = mock("lolz catz in_ur_fridge foodz")
      vector_11101_doc.stub!(:tokens).and_return([:lolz, :catz, :in_ur_fridge, :foodz])
      @lolz_catz = @prototype.new(vector_11101_doc)
      vector_01111_doc = mock("catz in_ur_fridge eatin_ur_foodz")
      vector_01111_doc.stub!(:tokens).and_return([:catz, :in_ur_fridge, :eatin_ur, :foodz])
      @eatin_ur_foodz = @prototype.new(vector_01111_doc)
    end
    
    # http://en.wikipedia.org/wiki/Jaccard_index
    # m_11 = 2; m_01 = 1; m_10 = 1;
    # (m_11) / (m_11 + m_01 + m_10) #=> 0.5
    it "should give the tanimoto coefficient for two vectors" do
      @lolz_catz.closeness(@eatin_ur_foodz).should == 0.6
    end
    
    it "should give a distance measurement using the hamming distance" do
      @lolz_catz.distance(@eatin_ur_foodz).should == 2
    end
    
    it "should AND with another vector to ``average''" do
      # @vectorizer.avg_binary_vectors([1,1,0,0,1], [1,0,0,1,1]).should == [1,0,0,0,1]
      result = @lolz_catz.average(@eatin_ur_foodz)
      result.should be_an_instance_of(@vector_class)
      result.to_a.should == [0,1,1,0,1]
    end

  end
  
end