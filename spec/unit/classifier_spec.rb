# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

describe Classifier do
  
  context "when initializing" do
    
    it "should store an algorithm type and N classes" do
      c = Classifier.new(:bayes, :spam, :ham, :sam)
      c.algorithm.should == :bayes
      c.class_names.should include(:spam, :ham, :sam)
    end
    
    it "should take a token transform block" do
      mock_doc = mock("ts")
      TrainingSet.should_receive(:new).and_yield(mock_doc)
      mock_doc.should_receive(:foo)
      c = Classifier.new(:bayes, :whatsis) do |doc|
        doc.foo
      end
    end
    
  end
    
  context "defining singleton||eigen methods for each class" do
    
    before do
      @training_set = mock("ts")
      TrainingSet.stub!(:new).and_return(@training_set)
      @classifier = Classifier.new(:bayes, :whatsis)
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
      @classifier = Classifier.new(:bayes, :deck, :so_last_year)
    end
    
    it "should classify documents" do
      @classifier.should_receive(:bayesian_scores_for_tokens).and_return({:so_last_year => 1, :deck => 0})
      @classifier.classify("java php").should == :so_last_year
    end
    
    it "should give the raw scores" do
      @classifier.should_receive(:bayesian_scores_for_tokens).and_return({:so_last_year => 1, :deck => 0})
      @classifier.scores("java php").should == {:deck => 0, :so_last_year => 1}
    end
  
  end
  
  context "detecting anomalies with the statistical algorithm" do
    
    before do
      @classifier = Classifier.new(:statistical, :normal)
    end
    
    it "should complain if asked to do anomaly detection and it has 2+ classes" do
      strange_request = lambda { Classifier.new(:bayes, :spam, :ham).anomalous?("text")}
      strange_request.should raise_error
    end
    
    it "should classify a document as anomalous the document has an anomaly score > 3" do
      @classifier.normal.should_receive(:anomaly_score_of_document).with("rubyist loving java").and_return(11)
      @classifier.anomalous?("rubyist loving java").should be_true
    end
    
  end
  
end
