# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

describe TokenTransforms do
  
  before(:each) do
    @ts = mock("TrainingSet")
  end
  
  context "converting raw tokens to domain tokens" do
    
    it "should convert basic text to tokens using {WS . , ; : \" '} as the delimeter set" do
      doc = Document.new(@ts, "the original.text,with;some:extra\"delimiters'amirite?yo")
      doc.plain_text
      doc.domain_tokens.should == %w{ the original text with some extra delimiters amirite yo}
    end
    
    it "should convert URIs to tokens using {& ? \\\\ \\ \/\/ \/ = [ ] .. .} as the delimeter set" do
      doc = Document.new(@ts, %q{a/URI/with?all[of]the=delimeters&in\\the..set.html})
      doc.uri
      doc.domain_tokens.should == %w{ a URI with all of the delimeters in the set html}
    end
    
  end
  
  context "transforming a document after domain tokens are set" do
    
    before(:each) do
      @doc = Document.new(@ts, "the original text")
      @doc.domain_tokens = %w{the original text}
    end
    
    it "should generate character-wise n-grams" do
      @doc.character_ngrams(:n => 2)
      @doc.additional_tokens.should == %w{ th he or ri ig gi in na al te ex xt}
    end
    
    it "should generate token-wise n-grams" do
      @doc.ngrams(:n => 2)
      @doc.additional_tokens.should == ["the original", "original text"]
    end
    
    it "should stem words with stemmer gem" do
      @doc.domain_tokens.each { |t| t.should_receive(:stem) }
      @doc.stem
    end
    
    it "should remove stop words" do
      @doc.remove_stopwords("ENGLISH_US")
      @doc.domain_tokens.should == %w{ original text }
    end
    
  end
  
end
