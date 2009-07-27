# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"

describe Clustering::Base do
  
  before do
    @clusterer = Clustering::Base.new
  end
  
  it "should create training set named :corpus" do
    @clusterer.classes[:corpus].should be_an_instance_of(TrainingSet)
    @clusterer.classes[:corpus].name.should == "corpus"
  end
  
  it "should add documents to the training set via #<<(doc text)" do
    @clusterer.classes[:corpus].should_receive(:<<)
    @clusterer << "some text"
  end
  
  it "should invalidate the cache when adding a document" do
    @clusterer.should_receive(:invalidate_cache)
    @clusterer << "some text"
  end
  
  it "should create the node tree from the documents in the training set" do
    @clusterer << "some text" << "some more text" << "even more text"
    pending("remove global state (class vars) from Clustering::Node")
    # clusterer should have built the node tree, and I should be able to print it (at least)
    #@clusterer.tree.print_tree
  end
  
end
