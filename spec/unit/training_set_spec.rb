# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

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
    @training_set = TrainingSet.new(@owner)
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
  
end
