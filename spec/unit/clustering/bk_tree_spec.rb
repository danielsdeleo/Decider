# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"

describe Clustering::BkTree do
  
  def vector_from_array(array)
    Vectors::Binary.from_array(array)
  end
  
  before do
    @bk_tree = Clustering::BkTree.new
  end
  
  it "should have a similar interface to the generic tree" do
    @bk_tree.should respond_to(:root)
    @bk_tree.should respond_to(:insert)
  end
  
  it "should be empty when initialized" do
    @bk_tree.root.should be_nil
  end
  
  it "should make the first inserted node the root" do
    vector_obj = vector_from_array([0,1,1,0])
    @bk_tree.insert(:first, vector_obj)
    @bk_tree.root.vector.should == vector_obj
  end
  
  context "after the root node is created" do
    
    before do
      @root_vector = vector_from_array([0,1,1,0])
      @bk_tree.insert(:root, @root_vector)
    end
    
    it "should attach new nodes to the root" do
      @vector_1_from_root = vector_from_array([0,1,1,1])
      @bk_tree.insert(:dist_1, @vector_1_from_root)
      @vector_2_from_root = vector_from_array([0,1,0,1])
      @bk_tree.insert(:dist_2, @vector_2_from_root)
      @bk_tree.root.should have(2).children
    end
    
    it "should attach new nodes under a pre-existing node if it is the same distance from the parent node" do
      @vector_1_from_root_a = vector_from_array([0,0,1,0])
      @vector_1_from_root_b = vector_from_array([0,1,1,1])
      @vector_1_from_root_c = vector_from_array([1,1,1,0])
      @bk_tree.insert(:dist_1_first, @vector_1_from_root_a)
      @bk_tree.insert(:dist_1_second, @vector_1_from_root_b)
      @bk_tree.insert(:dist_1_third, @vector_1_from_root_c)
      #puts @bk_tree.root.to_formatted_s
      @bk_tree.root.should have(1).children
      @bk_tree.root.children[1].should have(1).children
      @bk_tree.root.children[1].children[2].should have(1).children
    end
    
  end
  
  context "finding child nodes within a range" do
    
    before do
      @bk_tree.insert(:root, vector_from_array([0,1,1,0]))
      @bk_tree.insert(:root_plus_4, vector_from_array([1,0,0,1]))
      @bk_tree.insert(:root_plus_3, vector_from_array([1,1,0,1]))
      @bk_tree.insert(:root_plus_2, vector_from_array([1,1,1,1]))
      @bk_tree.insert(:root_plus_1, vector_from_array([1,1,1,0]))
    end
    
    it "should give the child nodes within a range " do
      #puts @bk_tree.root.to_formatted_s
      node_names = @bk_tree.root.children_in_range(2, 1).map { |node| node.name }
      node_names.should include(:root_plus_1)
      node_names.should include(:root_plus_2)
      node_names.should include(:root_plus_2)
      node_names.should_not include(:root_plus_4)
    end
    
  end
  
  context "finding nearest neighbors" do
    
    before do
      @ones_vectors = []
      5.times do |i|
        ary = Array.new(5, 1)
        ary[i] = 0
        v = vector_from_array(ary)
        @ones_vectors << v
        @bk_tree.insert("ones_#{i}".to_sym, v)
      end
      @zeroes_vectors = []
      5.times do |i|
        ary = Array.new(5, 0)
        ary[i] = 1
        v = vector_from_array(ary)
        @zeroes_vectors << v
        @bk_tree.insert("ones_#{i}".to_sym, v)
      end
      @bk_tree
    end
    
    it "should find the nearest neighbors within a given distance" do
      node_names =  @bk_tree.nearest_neighbors(1, vector_from_array([1,1,1,1,1])).map do |v|
        v.name.to_s
      end
      node_names.should have(5).items
      node_names.each {|n| n.should match(/ones_/)}
    end
    
  end
  
end
