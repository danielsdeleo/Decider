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
  
  context "with calls to methods that are supposed to be defined in subclasses" do
    
    before do
      @classifier = Classifier::Base.new(:one_class, :two_class)
    end
    
    it "should have a land mine for #classify" do
      lambda {@classifier.classify("whatever")}.should raise_error Classifier::NotImplementedError
    end
    
    it "should define #invalidate_cache so subclasses can call super in that method" do
      @classifier.should respond_to(:invalidate_cache)
    end
    
  end
  
end
