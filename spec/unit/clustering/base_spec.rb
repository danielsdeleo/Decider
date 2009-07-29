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
  
  it "should create a node tree from the documents in the training set" do
    @clusterer << "some text" << "some more text" << "even more text" << "yet more"
    # clusterer should have built the node tree, and I should be able to print it (at least)
    @clusterer.tree.should be_an_instance_of Clustering::Tree
    @clusterer.root_node.should be_an_instance_of Clustering::Node
    @clusterer.root_node.should have(2).children
    @clusterer.root_node.children.each { |c| c.should have(2).children }
  end
  
end
