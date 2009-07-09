# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

class BayesTestHarness
  include Bayes
end

describe Bayes do
  
  before(:each) do
    @bayes = BayesTestHarness.new
  end
  
  it "should give a term frequency hash for a token" do
    deck_ts = mock("deck training set")
    deck_ts.stub!(:term_frequency).and_return({:indie_rock => 10, :foreign_films => 7})
    weak_ts = mock("weak training set")
    weak_ts.stub!(:term_frequency).and_return({:foreign_films => 2, :pop_culture => 11})
    @bayes.stub!(:classes).and_return({:deck => deck_ts, :weak => weak_ts})
    @bayes.term_frequency_for_token(:foreign_films).should == {:deck => 7, :weak => 2}
    @bayes.term_frequency_for_token(:indie_rock).should == {:deck => 10, :weak => 0}
  end
  
  it "should give the probabilty of a token to be in each class" do
    @bayes.stub!(:term_frequency_for_token).and_return({:spammy => 5, :hammy => 3})
    @bayes.probabilities_for_token("spammy_token").should == {:spammy => 0.625, :hammy => 0.375}
  end
  
  it "should give 0.0 instead of NaN as the term frequency if the token hasn't been seen yet" do
    @bayes.stub!(:term_frequency_for_token).and_return({:spammy => 0, :hammy => 0})
    @bayes.probabilities_for_token("spammy_token").should == {:spammy => 0.0, :hammy => 0.0}
  end
  
  it "should give the probability for tokens to be in each class" do
    @bayes.stub!(:probabilities_for_token).and_return({:a => 0.8, :b => 0.1}, {:a => 1.0, :b => 0.3})
    @bayes.probabilities_for_tokens(["letter A", "all the way"]).should == {:a => 1.8, :b =>0.4}
  end
  
end
