# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

require "moneta/memory"

# Document is tricky to mock
class DocMock
  
  def initialize(text)
    @text = text
  end
  
  def tokens
    @text.split(" ")
  end
  
  def probability
    @ts.probability_of_tokens(tokens)
  end
  
end

describe TrainingSet do
  
  before(:each) do
    @owner = mock("training set owner", :null_object => true)
    @training_set = TrainingSet.new(:ts_name, @owner)
  end
  
  it "should be named" do
    @training_set.name.should == "ts_name"
  end
  
  context "working with training data" do 
    
    before do
      doc_init_proc = lambda { |doc| doc }
      @training_set.stub!(:document_callback).and_return(doc_init_proc)
      Document.stub!(:new).and_return { |text| DocMock.new(text)}
    end
    
    it "should store training tokens" do
      @training_set << "parameter" << "other_parameter"
      @training_set.tokens.should == ["parameter", "other_parameter"]
    end
  
    it "should store training documents" do
      @training_set << "one document" << "another document"
      @training_set.should have(2).documents
    end
  
    it "should increment the count for a token when given a duplicate" do
      @training_set << "cheese" << "cheese"
      @training_set.count_of("cheese").should == 2
    end
    
    it "should invalidate the cache of its owner when adding documents" do
      @owner.should_receive(:invalidate_cache)
      @training_set << "some stuff"
    end
  
  end
  
  context "with training data loaded" do
    TOKENS = %w{ 
      bullet.gif
      bullet.gif
      bullet1.gif
      bullet1.gif
      bullet2.gif
      bullet2.gif
      AQV3N2.jpg
      AQV3N2.jpg
      menutree.js
      menutree.js
      menutree.js
      plus.gif
      minus.gif
      minus.gif
      spacer.gif
      spacer.gif
      calendar.do
      contact.do 
      type 
      technical
    }

    
    before(:each) do
      Document.stub!(:new).and_return { |text| DocMock.new(text)}
      doc_init_proc = lambda { |doc| doc }
      @training_set.stub!(:document_callback).and_return(doc_init_proc)
      TOKENS.each { |token| @training_set << token }
    end
    
    it "should give a term frequency hash" do
      expected = {'bullet.gif'=>2,'bullet1.gif'=>2,'bullet2.gif'=>2,'AQV3N2.jpg'=>2,"menutree.js"=>3,
                  'plus.gif'=>1,'minus.gif'=>2,'spacer.gif'=>2,'calendar.do'=>1,'contact.do'=>1,"type"=>1,
                  'technical'=>1}
      @training_set.term_frequency.should == expected
    end
    
    it "should give the document count" do
      @training_set.doc_count.should == 20
    end
    
  end
  
  context "initializing documents" do
    
    before(:each) do
      @doc = mock("mock doc")
      @doc.stub!(:tokens).and_return([])
      Document.stub!(:new).and_return(@doc)
    end
    
    it "should store a block for initializing documents" do
      @training_set.tokenize do |doc|
        doc.foo
        doc.bar
      end
      @doc.should_receive(:foo)
      @doc.should_receive(:bar)
      @training_set.document_callback.call(@doc)
    end
    
    it "should call the block when creating a document" do
      document = mock("mock doc")
      @training_set.should_receive(:new_document).with("some text").and_return(document)
      document.should_receive(:tokens).and_return([])
      @training_set << "some text"
    end
    
  end
  
  context "storing to a moneta key value store" do
    
    # classifier
    #  |--training set "A"
    #  |
    #  `--training set "B" 
    #       |--documents      
    #       |--token "A" => count
    #       `--token "B"=> count
    # 
    # classifier.name::training_set.name::documents=>[docs]
    # classifier.name::training_set.name::tokens=>{tokens}
    
    before do
      @kv_store = Moneta::Memory.new
      @owner.stub!(:store).and_return(@kv_store)
      @owner.stub!(:name).and_return("snoop")
      @training_set = TrainingSet.new(:ts_name, @owner) { |doc| doc.plain_text }
      @training_set << "doc one" << "doc two"
    end
    
    it "should save documents and tokens to a moneta store" do
      @training_set.save
      @kv_store["snoop::ts_name::documents"].should have(2).documents
      @kv_store["snoop::ts_name::tokens"].should ==  {"two"=>1, "doc"=>2, "one"=>1}
    end
    
    it "should load documents from a moneta store" do
      docs = [DocMock.new("Doc A"), DocMock.new("Doc B")]
      @kv_store["snoop::ts_name::documents"] = docs
      tokens = {"A" => 1, "B" => 1, "Doc" => 2}
      @kv_store["snoop::ts_name::tokens"] = tokens
      @training_set.load
      @training_set.documents.should == docs
      @training_set.instance_variable_get(:@tokens).should == tokens
    end
    
  end
  
end
