# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

class DocumentHelperTestHarness
  include DocumentHelper
end

describe DocumentHelper do
  
  before(:each) do
    @doc_helper = DocumentHelperTestHarness.new
  end
  
  it "should create an accessor for the document creation callback" do
    @doc_helper.document_callback = lambda {|text| "#{text} cheese" }
    @doc_helper.document_callback.call("feed me").should == "feed me cheese"
  end
  
  it "should create a new document and call the callback on it" do
    @doc_helper.document_callback = lambda { |doc| doc.a_poke }
    document = mock("mock doc")
    document.should_receive(:a_poke)
    Document.should_receive(:new).with(:name, "whateva").and_return(document)
    @doc_helper.new_document(:name, "whateva")
  end
  
end
