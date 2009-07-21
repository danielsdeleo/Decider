# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"

describe Classifier::Base do
  
  context "when initializing" do
    
    it "should have N classes" do
      c = Classifier::Base.new(:spam, :ham, :blam)
      c.class_names.should include(:spam, :ham, :blam)
    end
    
    it "should take a token transform block" do
      mock_doc = mock("ts")
      TrainingSet.should_receive(:new).and_yield(mock_doc)
      mock_doc.should_receive(:foo)
      c = Classifier::Base.new(:whatsis) do |doc|
        doc.foo
      end
    end
    
  end
    
  context "defining singleton||eigen methods for each class" do
    
    before do
      @training_set = mock("ts")
      TrainingSet.stub!(:new).and_return(@training_set)
      @classifier = Classifier::Base.new(:bayes, :whatsis)
    end
    
    it "should create a training set for each class and define an accessor for it" do
      @classifier.whatsis.should == @training_set
    end

    it "should create a predicate method for each class to classify docs, like #spam?(email_text)" do
      @classifier.should respond_to :whatsis?
    end

  end
  
  context "classifying documents with the bayesian algorithm" do
    
    before do
      @classifier = Classifier::Base.new(:bayes, :deck, :weak)
    end
    
    it "should classify documents" do
      @classifier.should_receive(:bayesian_scores_for_tokens).and_return({:weak => 1, :deck => 0})
      @classifier.classify("java php").should == :weak
    end
    
    it "should give the raw scores" do
      @classifier.should_receive(:bayesian_scores_for_tokens).and_return({:weak => 1, :deck => 0})
      @classifier.scores("java php").should == {:deck => 0, :weak => 1}
    end
    
    it "should give the scores of the documents in each class" do
      @classifier.deck << "two deck" << "documents"
      @classifier.weak << "and one weak one"
      @classifier.stub!(:bayesian_scores_for_tokens).and_return({:deck =>0.9, :weak => 0.1},
                                                                {:deck =>0.6,:weak => 0.4},
                                                                {:deck =>0.8,:weak => 0.2})
      expected = {:deck => [0.9, 0.6, 0.8], :weak => [0.1, 0.4, 0.2] }
      @classifier.scores_of_all_documents.should == expected
    end
  
  end
  
  context "detecting anomalies with the statistical algorithm" do
    
    before do
      @classifier = Classifier::Base.new(:normal)
    end
    
    it "should complain if asked to do anomaly detection and it has 2+ classes" do
      strange_request = lambda { Classifier::Base.new(:bayes, :spam, :ham).anomalous?("text")}
      strange_request.should raise_error
    end
    
    it "should classify a document as anomalous the document has an anomaly score > 3" do
      @classifier.normal.should_receive(:anomaly_score_of_document).with("rubyist loving java").and_return(11)
      @classifier.anomalous?("rubyist loving java").should be_true
    end
    
  end
  
end
