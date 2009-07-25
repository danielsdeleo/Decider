# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"

module Moneta
  class MockStore
    
  end
end

module DefLoad
  def load(*args)
  end
end

describe Classifier::Base do
  
  context "when initializing" do
    
    it "should have N classes" do
      c = Classifier::Base.new(:spam, :ham, :blam)
      c.class_names.should include(:spam, :ham, :blam)
    end
    
    it "should take a token transform block" do
      mock_doc = mock("ts")
      TrainingSet.should_receive(:new).with(:whatsis, instance_of(Classifier::Base)).and_yield(mock_doc)
      mock_doc.should_receive(:foo)
      c = Classifier::Base.new(:whatsis) do |doc|
        doc.foo
      end
    end
    
    it "should give the training sets in a sorted array so things work correctly for Ruby 1.8 luddites" do
      c = Classifier::Base.new(:z, :n, :a)
      sorted = c.sorted_classes
      sorted.each { |klass| klass.should be_instance_of(TrainingSet) }
      sorted.map { |klass| klass.name.to_s }.should == ["a", "n", "z"]
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
  
  context "saving to moneta" do
    
    before do
      @classifier = Classifier::Base.new(:hot, :not)
    end
    
    it "should store the classifier name and return itself" do
      @classifier.save_as(:hot_or_not).should == @classifier
      @classifier.name.should == "hot_or_not"
    end
    
    it "should magically require the needed Moneta lib file and create a moneta obj" do
      @classifier.should_receive(:require).with("moneta/mock_store")
      Moneta::MockStore.should_receive(:new).with("mock store opts")
      @classifier.save_as(:hot_not).to(:mock_store, "mock store opts")
    end
    
    context "after moneta store is initialized" do
      
      before do
        @classifier.stub!(:require)
        Moneta::MockStore.stub!(:new).and_return("a delicious cookie")
        @classifier.save_as(:hot_not).to(:mock_store, "mock store opts")
      end
    
      it "should save by calling #save on its training sets" do
        @classifier.hot.should_receive(:save)
        @classifier.not.should_receive(:save)
        @classifier.save
        @classifier.store.should == "a delicious cookie"
      end
    
      it "should load by calling #load on its training sets" do
        @classifier.classes.each_value { |ts| ts.extend DefLoad } #Kernel.load is angry
        @classifier.hot.should_receive(:load)
        @classifier.not.should_receive(:load)
        @classifier.load
      end
      
    end
    #c = Classifier::Base.new(:deck, :wack)
    ## syntax A
    #c.store_as("deck_or_wack").to(:data_mapper, *moneta_dm_args) 
    ## Syntax B
    #c.store_as("deck_or_wack")
    #c.store_to(:data_mapper, *moneta_dm_args)
    ## Then
    # c.save
    # c.load
  end
  
end
