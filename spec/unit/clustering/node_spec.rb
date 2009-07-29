# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"

describe Clustering::Tree do
  T = Clustering::Tree
  
  
  it "should create the root node when initialized" do
    T.new.root.should be_an_instance_of(Clustering::Node)
  end
  
  context "adding new nodes to the tree" do
    
    before do
      @tree = T.new
    end
    
    it "should create a new node" do
      node = mock("node", :null_object => true)
      Clustering::Node.should_receive(:new).with(:a_new_node, [1,0]).and_return(node)
      @tree.insert(:a_new_node, [1,0])
    end
    
    it "should insert a new node into the tree" do
      @tree.root.should_receive(:attach).with(instance_of(Clustering::Node))
      @tree.insert(:new_node, [1,1,0,0])
    end
    
    it "should print the tree" do
      @tree.root.should_receive(:to_formatted_s).with(0, {:include_vectors => true})
      @tree.to_formatted_s(:include_vectors => true)
    end
    
  end
  
end

describe Clustering::Node do
  C = Clustering::Node
  
  before do
    @root_node = C.new(:root, [0])
    @high_vector = C.new(:high, [1,1,0,0])
    @low_vector = C.new(:low, [0,0,1,1])
  end
  
  it "should attach the first two nodes to the root node" do
    @root_node.attach(@high_vector)
    @root_node.attach(@low_vector)
    @root_node.should have(2).children
  end
  
  context "with nodes attached to the root" do
    
    before do
      @root_node.attach(@high_vector)
      @root_node.attach(@low_vector)
      @test_high = C.new(:test_high, [1,1,0,0])
      @test_low = C.new(:test_low, [0,0,1,1])
    end
    
    it "should support arbitrary vectoring methods" do
      pending
    end
  
    it "should find the closest vector " do
      @root_node.index_of_child_closest_to(@test_high).should == 0
      @root_node.index_of_child_closest_to(@test_low).should == 1
    end
  
    it "should create a new subnode with the best matching child" do
      subnode = @root_node.create_subnode(@test_high)
      subnode.vector.should == [1,1,0,0]
      subnode.should have(2).children
      subnode.children.should include(@high_vector)
      subnode.children.should include(@test_high)
      subnode.children.each { |child_node| child_node.parent.should == subnode }
    end
  
    it "should create intermediate subnodes so that no node has more than 2 children" do
      @root_node.attach(@test_high)
      @root_node.attach(@test_low)
      @root_node.should have(2).children
      @root_node.children.each {|child_node| child_node.should have(2).children}
    end
  
  end
  
end
