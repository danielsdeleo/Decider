# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"

class ExampleSubclass < Vectors::AbstractBase
  attr_reader :was_duplicated
  
  distances do |other_vector|
    "42" + other_vector.to_s
  end
  
  similarities do |other_vector|
    "23" + other_vector.to_s
  end
  
  averages do |other_vector|
    "815" + other_vector.to_s
  end
  
  def convert_document(whatever)
    nil
  end
  
  def duplicated
    @was_duplicated = true
  end
  
end

describe Vectors::AbstractBase do
  
  before do
    @base = Vectors::AbstractBase.new({})
  end
  
  it "should have method stubs for :closeness, :average, :distance" do
    lambda {@base.similarity(nil)}.should raise_error Decider::NotImplementedError
    lambda {@base.average(nil)}.should raise_error Decider::NotImplementedError
    lambda {@base.distance(nil)}.should raise_error Decider::NotImplementedError
  end
  
  it "should create a prototype vector from a token index hash" do
    token_indices = {:some => 0, :tokens => 1, :in_a => 2, :hash => 3}
    v = Vectors::AbstractBase.prototype(token_indices)
    v.index_of.should == token_indices
  end
  
  it "should define #new on the prototype vector" do
    v = Vectors::AbstractBase.prototype({:a_token => 0})
    v.should respond_to(:new)
  end
  
  it "should have a cache object for distance, average, and closeness" do
    v = Vectors::AbstractBase.prototype({:a_token => 0})
    v.distances.should be_a_kind_of Vectors::AbstractBase::ComputationCache
    v.similarities.should be_a_kind_of Vectors::AbstractBase::ComputationCache
    v.averages.should be_a_kind_of Vectors::AbstractBase::ComputationCache
  end
  
  it "should determine equality by comparing vectors" do
    v1, v2 = @base.dup, @base.dup
    v1.vector = [1,2,3]
    v2.vector = [1,2,3]
    v1.should_not equal v2
    v1.should == v2
    v2.vector = [2,3,4]
    v1.should_not == v2
  end
  
  it "should convert to an array by returning the vector attribute" do
    v1 = @base.dup
    @vector_attr = [8,15]
    v1.vector = @vector_attr
    v1.to_a.should equal @vector_attr
  end
  
  context "creating new vectors from the prototype" do
    
    before do
      @token_indices = {:lolz => 0, :catz => 1, :in_ur_fridge => 2, :eatin_ur_foodz => 3}
      @prototype = ExampleSubclass.prototype(@token_indices)
      @doc = mock("lolz document")
      @doc.stub!(:tokens).and_return([:lolz, :in_ur_fridge, :lolz])
      @new_v = @prototype.new(@doc)
    end
    
    it "should create a vector from a document" do
      @new_v.should be_an_instance_of ExampleSubclass
      @new_v.should_not equal(@prototype)
      @new_v.was_duplicated.should be_true
    end
    
    it "should give access to the identical cache objects to the children" do
      @new_v.distances.should equal @prototype.distances
      @new_v.similarities.should equal @prototype.similarities
      @new_v.averages.should equal @prototype.averages
    end
    
  end
  
  context "caching" do
    
    before do
      @vector = ExampleSubclass.prototype({:a_token=>1})
      @other = :other_vector
    end
    
    it "should define distance computations in a block and handle caching automatically" do
      @vector.distances.lookup(@vector, @other).should be_nil
      @vector.distance(@other)
      @vector.distances.lookup(@vector, @other).should == "42other_vector"
    end
    
    it "should define closeness computations in a block and handle caching automatically" do
      @vector.similarities.lookup(@vector, @other).should be_nil
      @vector.similarity(@other)
      @vector.similarities.lookup(@vector, @other).should == "23other_vector"
    end
    
    it "should define average computations in a block and handle caching automatically" do
      @vector.averages.lookup(@vector, @other).should be_nil
      @vector.average(@other)
      @vector.averages.lookup(@vector, @other).should == "815other_vector"
    end
    
  end
  
  describe Vectors::AbstractBase::ComputationCache do
    before do
      @cache = Vectors::AbstractBase::ComputationCache.new
    end
    
    it "should return nil for cache misses" do
      @cache.lookup(:unknown_vector, :another_unknown).should be_nil
    end
    
    it "should cache computations between two vectors" do
      @cache.store(:vectors =>[:vector_a, :vector_b], :result => 12345)
      @cache.lookup(:vector_a, :vector_b).should == 12345
    end
    
    it "should cache the result for the vectors in reverse order" do
      @cache.store(:vectors =>[:vector_a, :vector_b], :result => 12345)
      @cache.lookup(:vector_b, :vector_a).should == 12345
    end
    
    it "should return the result value when storing" do
      @cache.store(:vectors =>[:a,:b], :result=>123).should == 123
    end
    
  end
  
end
