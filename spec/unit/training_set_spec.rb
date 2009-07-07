# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

# Document is tricky to mock
class DocMock
  
  def initialize(ts, text)
    @ts = ts
    @text = text
  end
  
  def tokens
    @text.split(" ")
  end
  
  def probability
    @ts.probability_of_tokens(tokens)
  end
  
end

describe TrainingSet do
  
  before(:each) do
    @training_set = TrainingSet.new
  end
  
  context "working with training data" do 
    
    before do
      doc_init_proc = lambda { |doc| doc }
      @training_set.stub!(:new_document_callback).and_return(doc_init_proc)
      Document.stub!(:new).and_return { |ts, text| DocMock.new(ts, text)}
    end
    
    it "should store training tokens" do
      @training_set << "parameter" << "other_parameter"
      @training_set.tokens.should == ["parameter", "other_parameter"]
    end
  
    it "should store training documents" do
      @training_set << "one document" << "another document"
      @training_set.should have(2).documents
    end
  
    it "should increment the count for a token when given a duplicate" do
      @training_set << "cheese" << "cheese"
      @training_set.count_of("cheese").should == 2
    end
  
    it "should find the vector (array) index for a token" do
      @training_set << "parameter" << "other_parameter"
      @training_set.index_of("other_parameter").should == 1
    end
  
    it "should not fail when trying to find the vector index for a token not in the set" do
      @training_set << "a_parm"
      lambda {@training_set.index_of("unknown_token")}.should_not raise_error
    end
  
    it "should generate a vector representation of a list of tokens" do
      @training_set << "parameter" << "other_parm" << "exploitable_php_app.php"
      @training_set.vectorize(["parameter", "other_parm"]).should == [1,1,0]
    end
  
    it "should not fail when generating a vector for a term with unknown tokens" do
      @training_set << "parameter" << "other_parm" << "exploitable_php_app.php"
      @training_set.vectorize(["unknown_tokens"]).should == [0,0,0]
    end
  
    it "should compute the total number of tokens and cache it" do
      @training_set << "cheese" << "dumpster" << "oldskool"
      @training_set.total_tokens.should == 3
      @training_set << "cheese" << "dumpster" << "oldskool"
      @training_set.total_tokens.should == 6
    end
  end
  
  context "with training data loaded" do
    TOKENS = %w{ 
      bullet.gif
      bullet.gif
      bullet1.gif
      bullet1.gif
      bullet2.gif
      bullet2.gif
      AQV3N2.jpg
      AQV3N2.jpg
      menutree.js
      menutree.js
      menutree.js
      plus.gif
      spacer.gif
      minus.gif
      spacer.gif
      minus.gif
      calendar.do
      contact.do 
      type 
      technical
    }

    
    before(:each) do
      Document.stub!(:new).and_return { |ts, text| DocMock.new(ts, text)}
      doc_init_proc = lambda { |doc| doc }
      @training_set.stub!(:new_document_callback).and_return(doc_init_proc)
      TOKENS.each { |token| @training_set << token }
    end
    
    it "should give the probability of a token in the set" do
      @training_set.probability_of_token("bullet.gif").should == (2.0 / 20.0)
    end
    
    it "should give the probability of a set of tokens" do
      prob = @training_set.probability_of_tokens(["bullet.gif", "bullet2.gif", "technical"])
      prob.should == ((2.0/ 20.0) + (2.0/ 20.0) + (1.0 / 20.0)) / 3.0
    end
    
    it "should give the probability of a set of tokens that includes an unknown token" do
      prob = @training_set.probability_of_tokens(["bullet.gif", "bullet2.gif", "unknown_token"])
      prob.should == ((2.0/ 20.0) + (2.0/ 20.0) + (0.0 / 20.0)) / 3.0
    end
    
    it "should give the probabilty of a document" do
      prob = @training_set.probability_of_document("bullet.gif bullet2.gif unknownToken")
      prob.should == ((2.0/ 20.0) + (2.0/ 20.0) + (0.0 / 20.0)) / 3.0
    end
    
    it "should compute the probabilities of all documents" do
      expected = TOKENS.map { |t| @training_set.probability_of_token(t) }.sort
      @training_set.probabilities_of_documents.sort.should == expected
    end
    
    it "should give the average probability of the documents" do
      expected_probs = TOKENS.map { |t| @training_set.probability_of_token(t) }
      expected_avg = expected_probs.inject(0) { |sum, prob| sum + prob } / TOKENS.count.to_f
      @training_set.avg_document_probability.should == expected_avg
    end
    
    it "should give the standard deviation in document probabilities" do
      @training_set.document_score_stddev.should be_close(0.0312, 0.0001)
    end
    
    it "should give the number of standard deviations a document is from the mean" do
      expected = 0.005 / @training_set.document_score_stddev
      @training_set.distance_from_avg_in_stddevs(["bullet.gif"]).should be_close(expected, 0.00000001)
    end
    
    it "should give the stddev distance for an unknown token" do
      expected = -1 * @training_set.avg_document_probability / @training_set.document_score_stddev
      @training_set.distance_from_avg_in_stddevs(["unknown_token"]).should be_close(expected, 0.00000001)
    end
    
    it "should compute an ``anomaly score'' == {0 if prob - avg > 0; #of std devs if prob - avg < 0} " do
      expected = @training_set.avg_document_probability / @training_set.document_score_stddev
      @training_set.anomaly_score_of(["unknown_token"]).should be_close(expected, 0.00000001)
      @training_set.anomaly_score_of(["bullet.gif"]).should == 0
    end
    
    it "should memoize the results of #anomaly_score_of(tokens)" do
      @training_set.should_receive(:distance_from_avg_in_stddevs).once.and_return(3.0)
      @training_set.anomaly_score_of(["unknown_token"])
      @training_set.anomaly_score_of(["unknown_token"])
    end
    
  end
  
  context "initializing documents" do
    
    before(:each) do
      @doc = mock("mock doc")
      @doc.stub!(:tokens).and_return([])
      Document.stub!(:new).and_return(@doc)
    end
    
    it "should store a block for initializing documents" do
      @training_set.tokenize do |doc|
        doc.foo
        doc.bar
      end
      @doc.should_receive(:foo)
      @doc.should_receive(:bar)
      @training_set.new_document_callback.call(@doc)
    end
    
    it "should call the block when creating a document" do
      @doc.should_receive(:foo)
      @training_set.tokenize { |doc| doc.foo }
      @training_set << "some text"
    end
    
    it "should have a default callback suitable for plaintext" do
      @doc.should_receive(:plain_text)
      @doc.should_receive(:stem)
      @training_set << "some text"
    end
    
  end
  
end
