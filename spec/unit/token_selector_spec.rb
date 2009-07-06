# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

## Find a way to make an API like this work! ##
#t = TokenSelector.new
#t.transforms do |doc|
#  doc.explode_uri
#  doc.character_wise_ngrams(:n => 3)
#  doc.token_wise_ngrams(:n => 2)
#end
#

describe TokenSelector::BasePaths do
  
  before(:each) do
    @base_paths = TokenSelector::BasePaths.new
  end
  
  it "should be enumerable" do
    @base_paths.should respond_to :each
    @base_paths.should respond_to :<<
    @base_paths.should respond_to :length
  end
  
  it "should accept strings or regexes and convert them to regexes" do
    @base_paths << "/path/to/resource"
    @base_paths << Regexp.new(Regexp.escape "/path/to/other/resource")
    @base_paths.each { |path| path.should be_a_kind_of Regexp }
  end
  
  it "should return match data for all matches" do
    @base_paths << "/path/" << "/path/to/" << "/path/to/resource"
    result = @base_paths.match_to("/path/to/resource/param")
    result.should have(3).items
    result.each { |md| md.should respond_to(:post_match) }
  end
  
end

describe TokenSelector do
  
  before(:each) do
    @selector = TokenSelector.new
  end
  
  it "should keep a list of base paths to ignore" do
    @selector.should respond_to :base_paths
    @selector.base_paths.should respond_to :<<
    @selector.base_paths.should respond_to :each
  end
  
  it "should accept an input string and output a list of parameters" do
    @selector.parameters("/path/to/resource").should be_an(Array)
  end
  
  it "should select the shortest results" do
    @selector.select_best_result_from(["1", "12", "123"]).should == "1"
    @selector.select_best_result_from(["1", "12"]).should == "1"
    @selector.select_best_result_from(["/param1/param2", "/one/param1/param2"]).should == "/param1/param2"
  end
  
  it "should remove base paths from URIs" do
    @selector.base_paths << "/path/to/resource/one"
    @selector.base_paths << "/path/to/resource"
    @selector.remove_base_paths("/path/to/resource/one/param1/param2").should == "/param1/param2"
  end
  
  it "should remove base paths from URIs before extracting parameters" do
    @selector.base_paths << "/static_docs/css/main.css"
    @selector.parameters("/static_docs/css/main.css").should == []
    @selector.base_paths << "/controller/action/"
    @selector.parameters("/controller/action/pretty/url/parms").should == %w{ pretty url parms}
  end
  
  it "should extract character-wise n-grams from parameters" do
    bigrams = @selector.extract_ngrams("parameter", :n => 2)
    bigrams.should == %w{ pa ar ra am me et te er}
  end
  
  it "should extract n-grams from the parameters in an uri" do
    @selector.ngrams("/path/to/resource").should == %w{ pa at th to re es so ou ur rc ce}
  end
  
end
