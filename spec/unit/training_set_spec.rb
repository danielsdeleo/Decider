# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

describe TrainingSet do
  
  before(:each) do
    @training_set = TrainingSet.new
  end
  
  it "should store training data" do
    @training_set << "parameter" << "other_parameter"
    @training_set.tokens.should == ["parameter", "other_parameter"]
  end
  
  it "should increment the count for a token when given a duplicate" do
    @training_set << "cheese" << "cheese"
    @training_set.count_of("cheese").should == 2
  end
  
  it "should generate a vector index for the tokens" do
    @training_set << "parameter" << "other_parameter"
    @training_set.index_of("other_parameter").should == 1
  end
  
  it "should generate a vector representation of a list of tokens" do
    @training_set << "parameter" << "other_parm" << "exploitable_php_app.php"
    @training_set.vectorize(["parameter", "other_parm"]).should == [1,1,0]
  end
  
  it "should compute the total number of tokens and cache it" do
    @training_set << "cheese" << "dumpster" << "oldskool"
    @training_set.total_tokens.should == 3
    @training_set << "cheese" << "dumpster" << "oldskool"
    @training_set.total_tokens.should == 6
  end
  
end

describe TrainingSet::Token do
  
  before(:each) do
    @token = TrainingSet::Token.new("foobarbaz", :index => 5)
  end
  
  it "should have a string, count, and index" do
    token = TrainingSet::Token.new("foobarbaz", :index => 5)
    token.to_s.should == "foobarbaz"
    token.index.should == 5
    token.count.should == 1
  end
  
  it "should increment the count" do
    @token.increment
    @token.count.should == 2
  end
end
