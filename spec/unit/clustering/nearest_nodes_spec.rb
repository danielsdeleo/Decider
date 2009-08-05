# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"

describe Clustering::NearestNodes do
  
  before do
    @nearest_nodes = Clustering::NearestNodes.new(:binary) { |doc| doc.plain_text }
  end
  
  it "should create a BK-Tree" do
    @nearest_nodes.tree.should be_an_instance_of(Clustering::BkTree)
  end
  
  it "should populate the BK-Tree with documents from the corpus" do
    @nearest_nodes << "some text" << "even more text" << "some more text" << "yet more" << "some drivel text"
    @nearest_nodes.tree.size.should == 5
  end
  
  context "finding neighbor documents" do
    
    before do
      @nearest_nodes << "some text" << "even more text" << "some more text" << "yet more" << "some drivel text"
    end
  
    it "should find documents within a given radius of a target" do
      @nearest_nodes.in_range(1, "some nonsense text").should have(3).results
    end
    
    it "should find the single nearest neighbor" do
      @nearest_nodes.nearest("some drivel text").name.raw.should == "some drivel text"
    end
  
    it "should find the K nearest neighbors" do
      pending
    end
  end
  
end
