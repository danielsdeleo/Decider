# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

describe Document do
  
  context "on initialization" do

    it "should initialize with a raw string" do
      Document.new("the original text").raw.should == "the original text"
    end

  end

  context "storing token manipulations" do

    before(:each) do
      @doc = Document.new("the original text")
    end

    it "should provide an array for domain tokens" do
      @doc.raw.split(" ").each { |token| @doc.domain_tokens << token }
      @doc.domain_tokens.should == %w{ the original text }
    end

    it "should support #domain_tokens(new_domain_tokens) because domain_tokens= creates an instance variable sometimes" do
      @doc.domain_tokens(%w{foo bar baz})
      @doc.domain_tokens.should == %w{foo bar baz}
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
      @doc = Document.new("the original text text")
      @doc.domain_tokens = %w{ the original text text }
      @doc.push_additional_tokens ["the original", "original text", "text text"]
    end

    it "should return domain tokens and additional tokens" do
      expected = (%w{ the original text text } + ["the original", "original text", "text text"]).sort
      @doc.tokens.map{ |t| t.to_s }.sort.should == expected
    end
    
  end
  
  context "to support extensibility" do

    module TestCustomTransforms

      def succ_it
        push_additional_tokens(domain_tokens.map { |t| t.succ })
      end

    end

    it "should provide a wrapper for include" do
      Document.custom_transforms(TestCustomTransforms)
      doc = Document.new("abc def")
      doc.plain_text
      doc.succ_it
      doc.additional_tokens.should == %w{abd deg}
    end

  end
end
