# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

describe TrainingSet do
  
  before(:each) do
    @training_set = TrainingSet.new
  end
  
  it "should store training tokens" do
    @training_set << "parameter" << "other_parameter"
    @training_set.tokens.should == ["parameter", "other_parameter"]
  end
  
  it "should store training documents" do
    @training_set << ["one", "document"] << ["another", "document"]
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
    
    # NOTE: if several documents are identical or have the same token
    # then the sum of these probabilities is gt 1. The distribution of 
    # probabilities will be weighted higher, that is, closer to the values
    # of the documents with "popular" tokens
    it "should compute the probabilities of all documents" do
      expected = TOKENS.map { |t| @training_set.probability_of_token(t) }.sort
      @training_set.probabilities_of_documents.sort.should == expected
    end
    
    # NOTE: see note above
    it "should give the average probability of the documents" do
      expected_probs = TOKENS.map { |t| @training_set.probability_of_token(t) }
      expected_avg = expected_probs.inject(0) { |sum, prob| sum + prob } / TOKENS.count.to_f
      @training_set.avg_document_probability.should == expected_avg
    end
    
    it "should give the standard deviation in document probabilities" do
      @training_set.document_score_stddev.should be_close(0.0312, 0.0001)
    end
    
    it "should give the number of standard deviations a document is from the mean" do
      #p "probability of ``bullet.gif:    " + @training_set.probability_of_tokens(["bullet.gif"]).to_s
      #p "avg probability of document:    " + @training_set.avg_document_probability.to_s
      #p "std deviation in probabilities: " + @training_set.document_score_stddev.to_s
      #p "# of stddevs from avg (bullet.gif): " + @training_set.distance_from_avg_in_stddevs(["bullet.gif"]).to_s
      #p "# of stddevs from avg (type): " + @training_set.distance_from_avg_in_stddevs(["type"]).to_s
      expected = 0.005 / @training_set.document_score_stddev
      @training_set.distance_from_avg_in_stddevs(["bullet.gif"]).should be_close(expected, 0.00000001)
    end
    
    it "should give the stddev distance for an unknown token" do
      #p "assumed probabilty of unknown token: " +  @training_set.probability_of_tokens(["unknown_token"]).to_s
      #p @training_set.distance_from_avg_in_stddevs(["unknown_token"])
      expected = -1 * @training_set.avg_document_probability / @training_set.document_score_stddev
      @training_set.distance_from_avg_in_stddevs(["unknown_token"]).should be_close(expected, 0.00000001)
    end
    
    it "should compute an ``anomaly score'' == {0 if prob - avg > 0; #of std devs if prob - avg < 0} " do
      expected = @training_set.avg_document_probability / @training_set.document_score_stddev
      @training_set.anomaly_score_of(["unknown_token"]).should be_close(expected, 0.00000001)
      @training_set.anomaly_score_of(["bullet.gif"]).should == 0
    end
    
    it "should memoize the results of #anomaly_score_of(tokens)" do
      @training_set.expects(:distance_from_avg_in_stddevs).once.returns(3.0)
      @training_set.anomaly_score_of(["unknown_token"])
      @training_set.anomaly_score_of(["unknown_token"])
    end
    
  end
  
end

describe TrainingSet::Document do
  
  context "when initializing" do
    
    before(:each) do
      @training_set = mock
    end
    
    it "should have one or more tokens" do
      doc = TrainingSet::Document.new(@training_set, "foo", "bar", "baz")
      doc.tokens.should == ["foo", "bar", "baz"]
    end
    
    it "should accept an array of tokens" do
      doc = TrainingSet::Document.new(@training_set, ["foo", "bar", "baz"])
      doc.tokens.should == ["foo", "bar", "baz"]
    end
    
    it "should be able to refer to its parent TrainingSet" do
      doc = TrainingSet::Document.new(@training_set, ["foo", "bar", "baz"])
      doc.training_set.should equal @training_set
    end
    
  end
  
  context "when analyzing its tokens" do
    
    before(:each) do
      @training_set = mock
      @document = TrainingSet::Document.new(@training_set, ["foo", "bar", "baz"])
    end
  
    it "should give the probability of its tokens" do
      @training_set.expects(:probability_of_tokens).with(["foo", "bar", "baz"])
      @document.probability
    end
    
  end
end
