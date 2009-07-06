# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

describe Doc do
  context "on initialization" do
    
    it "should initialize with a raw string" do
      Doc.new("the original text").raw.should == "the original text"
    end
    
  end
  
  context "storing token manipulations" do
    
    before(:each) do
      @doc = Doc.new("the original text")
    end
    
    it "should provide an array for domain tokens" do
      @doc.raw.split(" ").each { |token| @doc.domain_tokens << token }
      @doc.domain_tokens.should == %w{ the original text }
    end
    
    it "should provide an array for additional tokens" do
      @doc.additional_tokens << "foo" << "bar" << "baz"
      @doc.additional_tokens.should == %w{foo bar baz}
    end
    
    it "should allow domain tokens to be set directly " do
      @doc.domain_tokens = %w{some tokens}
      @doc.domain_tokens.should == %w{some tokens}
    end
    
    it "should allow additional tokens to be pushed en masse" do
      @doc.push_additional_tokens %w{ foo bar baz}
      @doc.additional_tokens.should == %w{ foo bar baz}
    end
    
  end
  
  context "returning tokens" do
    
    before(:each) do
      @doc = Doc.new("the original text")
      @doc.domain_tokens = %w{ the original text }
      @doc.push_additional_tokens ["the original", "original text"]
    end
    
    it "should return domain tokens and additional tokens" do
      @doc.tokens.should == %w{ the original text } + ["the original", "original text"]
    end
  end
end

describe TokenTransforms do
  
  context "converting raw tokens to domain tokens" do
    
    it "should convert basic text to tokens using {WS . , ; : \" '} as the delimeter set" do
      doc = Doc.new("the original.text,with;some:extra\"delimiters'yo")
      doc.plain_text
      doc.domain_tokens.should == %w{ the original text with some extra delimiters yo}
    end
    
    it "should convert URIs to tokens using {& ? \\\\ \\ \/\/ \/ = [ ] .. .} as the delimeter set" do
      doc = Doc.new(%q{a/URI/with?all[of]the=delimeters&in\\the..set.html})
      doc.uri
      doc.domain_tokens.should == %w{ a URI with all of the delimeters in the set html}
    end
    
  end
  
  context "transforming a document after domain tokens are set" do
    
    before(:each) do
      @doc = Doc.new("the original text")
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
      @doc.domain_tokens.each { |t| t.expects(:stem) }
      @doc.stem
    end
    
    it "should remove stop words" do
      @doc.remove_stopwords("ENGLISH_US")
      @doc.domain_tokens.should == %w{ original text }
    end
    
  end
  
  
end
