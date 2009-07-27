# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"

describe Clustering::Node do
  CNode = Clustering::Node
  
  before do
    CNode.reset!
    @high_vector = CNode.new(:high, [1,1,0,0])
    @low_vector = CNode.new(:low, [0,0,1,1])
    @test_high = CNode.new(:test_high, [1,1,0,0], :virtual_node =>true)
    @test_low = CNode.new(:test_low, [0,0,1,1], :virtual_node => true)
    #CNode.print_tree(:include_vectors => true)
  end
  
  it "should attach the first two nodes to the root node" do
    CNode.root_node.should have(2).children
  end
  
  it "should find the closest vector " do
    CNode.root_node.index_of_child_closest_to(@test_high).should == 0
    CNode.root_node.index_of_child_closest_to(@test_low).should == 1
  end
  
  it "should create a new subnode with the best matching child" do
    subnode = CNode.root_node.create_subnode(@test_high)
    subnode.vector.should == [1,1,0,0]
    subnode.should have(2).children
    subnode.children.should include(@high_vector)
    subnode.children.should include(@test_high)
    subnode.children.each { |child_node| child_node.parent.should == subnode }
  end
  
  it "should create intermediate subnodes so that no node has more than 2 children" do
    CNode.new(:test_high_2, [1,1,0,0])
    CNode.new(:test_low_2, [0,0,1,1])
    CNode.print_tree
    CNode.root_node.should have(2).children
    CNode.root_node.children.each {|child_node| child_node.should have(2).children}
  end
  
  it "should um... idunnoyet" do
    CNode.new(:low_a, [1,1])
    CNode.new(:child_b, [1,1])
    CNode.new(:child_c, [1,1])
    CNode.new(:child_d, [1,1])
    CNode.new(:child_e, [1,1])
    CNode.root_node.print_subtree
  end
  
end
