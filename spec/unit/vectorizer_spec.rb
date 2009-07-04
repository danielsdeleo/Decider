# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

describe Vectorizer do
  
  before(:each) do
    @vectorizer = Vectorizer.new
  end
  
  it "should store training data" do
    @vectorizer.tokens << "parameter" << "other_parameter"
    @vectorizer.tokens.should == ["parameter", "other_parameter"]
  end
  
  it "should generate a vector index for the tokens" do
    @vectorizer.tokens << "parameter" << "other_parameter"
    @vectorizer.index_of("other_parameter").should == 1
  end
  
  it "should generate a vector representation of a list of tokens" do
    @vectorizer.tokens << "parameter" << "other_parm" << "exploitable_php_app.php"
    @vectorizer.vectorize(["parameter", "other_parm"]).should == [1,1,0]
  end
  
end
