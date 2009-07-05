# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

describe Token do

  context "when initializing" do
    it "should have a string, count, and index" do
      token = TrainingSet::Token.new("foobarbaz", :index => 5)
      token.to_s.should == "foobarbaz"
      token.index.should == 5
      token.count.should == 1
    end
  end

  context "when counting occurrences" do

    before(:each) do
      @token = Token.new("foobarbaz", :index => 5)
    end

    it "should increment the count" do
      @token.increment
      @token.count.should == 2
    end

    it "should add another token to itself" do
      other_token = Token.new("foobarbaz", :index => 5)
      other_token.increment
      @token.count.should == 1
      other_token.count.should == 2
      combined_token = @token + other_token
      combined_token.count.should == 3
    end

    it "should merge with another token" do
      other_token = Token.new("foobarbaz", :index => 5)
      3.times { other_token.increment }
      @token.merge(other_token)
      @token.count.should == 5
    end
    
    it "should refuse to add or merge with an unsuitable object" do
      lambda { @token + 25}.should raise_error(ArgumentError)
    end

  end
end
