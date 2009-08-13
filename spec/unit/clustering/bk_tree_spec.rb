# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"

describe Clustering::BkTree::Node do
  it "should give the correct nodes within a specified range" do
    node = Clustering::BkTree::Node.new(nil, nil)
    dummy_child_nodes = {1 => :one, 2 => :two, 3 => :three, 4 => :four, 5 => :five, 6 => :six, 7 => :seven}
    node.instance_variable_set(:@children, dummy_child_nodes)
    node.children_in_range(3, 1).should include(:two, :three, :four)
    node.children_in_range(2, 2).should include(:one, :two, :three, :four)
  end
end

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
  
  it "should store the document with the node and have an accessor for it" do
    @bk_tree.insert(:the_document, vector_from_array([1,0]))
    @bk_tree.root.document.should == :the_document
    @bk_tree.root.doc.should == :the_document
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
      node_names = @bk_tree.root.children_in_range(2, 1).map { |node| node.document }
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
    end
    
    it "should find the nearest neighbors within a given distance" do
      node_names =  @bk_tree.nearest_neighbors(1, vector_from_array([1,1,1,1,1])).map do |doc|
        doc.to_s
      end
      node_names.should have(5).items
      node_names.each {|n| n.should match(/ones_/)}
    end
    
    it "should find the single nearest neighbor" do
      three_up2down = vector_from_array([1,1,1,0,0])
      @bk_tree.insert(:three_up2down, three_up2down)
      @bk_tree.nearest_neighbor(vector_from_array([1,1,1,0,0])).should == :three_up2down
    end
    
    it "should find the K nearest neighbors" do
      results = @bk_tree.k_nearest_neighbors(5, vector_from_array([1,1,1,1,1]))
      results.should have(5).nodes
      results.each { |document| document.to_s.should match(/ones_/) }
    end
    
    it "should alias k_nearest_neighbors as knn" do
      @bk_tree.should respond_to(:knn)
    end
    
    it "should allow a distance limit to be specified for a KNN search" do
      target = vector_from_array([1,1,1,1,1])
      @bk_tree.should_receive(:find_nearest_neighbors).with(target, {:results => 3, :distance => 50})
      @bk_tree.knn(3, target, :distance => 50)
    end
    
    it "should delegate #to_formatted_s to the root node" do
      @bk_tree.root.should_receive(:to_formatted_s)
      @bk_tree.to_formatted_s
    end
    
    it "should return '' for #to_formatted_s if the root node is nil" do
      lambda {Clustering::BkTree.new.to_formatted_s}.should_not raise_error(NoMethodError)
    end
    
    it "should give its size" do
      Clustering::BkTree.new.size.should == 0
      @bk_tree.size.should == 10
    end
    
  end
  
end

describe Clustering::BkTree::Results do
  R = Clustering::BkTree::Results
  
  it "should find the best single result when :results => 1" do
    results = R.new(:results => 1)
    results[:not_good_enough] = 5
    results[:the_winner] = 2
    results.distance_limit.should == 2
    results.to_a.should == [:the_winner]
  end
  
  it "should find the best N results when :results => N" do
    results = R.new(:results => 3)
    results[:fail] = 8
    results[:ok] = 5
    results[:better] = 4
    results[:win] = 1
    results.distance_limit.should == 5
    results.to_a.should_not include(:fail)
    results.should have(3).nodes
  end
  
  it "should not accept results over an explicit limit" do
    results = R.new(:distance => 3)
    results[:fail] = 4
    results[:close_but_not_a_fail] = 3
    results[:good] = 2
    results[:awesome] = 1
    results.should have(3).nodes
  end
  
  it "should give nil as the distance limit if there are less than max results results" do
    results = R.new(:results => 5)
    results[:not_more_than_max] = 1
    results.distance_limit.should be_nil
  end
end
