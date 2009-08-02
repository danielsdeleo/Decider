# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"

describe Clustering::Base do
  
  before do
    @clusterer = Clustering::Base.new { |d| d.plain_text }
  end
  
  it "should create training set named :corpus" do
    @clusterer.corpus.should be_an_instance_of(TrainingSet)
    @clusterer.corpus.name.should == "corpus"
  end
  
  it "should add documents to the training set via #<<(doc text)" do
    @clusterer.corpus.should_receive(:<<)
    @clusterer << "some text"
  end
  
  it "should add named documents to the training set via #push" do
    @clusterer.corpus.should_receive(:push).with(:the_doc_name, "and its text")
    @clusterer.push(:the_doc_name, "and its text")
  end
  
  it "should invalidate the cache when adding a document" do
    @clusterer.should_receive(:invalidate_cache)
    @clusterer << "some text"
  end
  
  it "should take a vector type in the constructor and use it throughout" do
    c = Clustering::Base.new(:binary)
    c.vector_class.should == Vectors::Binary
  end
  
  it "should default to sparse binary vectors" do
    Clustering::Base.new.vector_class.should == Vectors::SparseBinary
  end
  
end
