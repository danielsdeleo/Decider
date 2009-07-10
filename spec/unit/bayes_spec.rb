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
  
  it "should split term frequencies into {:this => x, :other => y}" do
    @bayes.stub!(:term_frequency_for_token).and_return {{:good => 5, :bad => 7, :ugly => 13}.dup}
    @bayes.occurrences_of_token_in_class(:good, "a_token").should == {:this => 5, :other => 20}
    @bayes.occurrences_of_token_in_class(:bad, "a token").should == {:this => 7, :other => 18}
    @bayes.occurrences_of_token_in_class(:ugly, "a token").should == {:this => 13, :other => 12}
  end
  
  it "should give the document counts by class" do
    good_class = mock("good")
    good_class.stub!(:doc_count).and_return(5)
    bad_class = mock('bad')
    bad_class.stub!(:doc_count).and_return(7)
    ugly_class = mock('ugly')
    ugly_class.stub!(:doc_count).and_return(13)
    @bayes.stub!(:classes).and_return({:good => good_class, :bad => bad_class, :ugly => ugly_class})
    @bayes.document_counts_by_class(:good).should == {:this => 5, :other => 20}
    @bayes.document_counts_by_class(:bad).should == {:this => 7, :other => 18}
    @bayes.document_counts_by_class(:ugly).should == {:this => 13, :other => 12}
  end
  
  it "should use fallback values if a class has no documents" do
    good_class = mock("good")
    good_class.stub!(:doc_count).and_return(0)
    bad_class = mock('bad')
    bad_class.stub!(:doc_count).and_return(0)
    @bayes.stub!(:classes).and_return({:good => good_class, :bad => bad_class})
    @bayes.document_counts_by_class(:good).should == {:this => 1, :other => 1}
  end
  
  it "should compute the probabiltity of a token to be in a given class" do
    @bayes.stub!(:occurrences_of_token_in_class).and_return({:this => 15, :other => 20})
    @bayes.stub!(:document_counts_by_class).and_return({:this => 5, :other => 10})
    expected = (15.0 / 5.0) / ((15.0/ 5.0) + (20.0 / 10.0))
    @bayes.probability_of_token_in_class(:klass, "one token").should == expected
  end
  
  it "should fallback to a neutral value if the token hasn't been seen before" do
    @bayes.stub!(:occurrences_of_token_in_class).and_return({:this => 0, :other => 0})
    @bayes.stub!(:document_counts_by_class).and_return({:this => 1, :other => 1})
    @bayes.probability_of_token_in_class(:klass, "one token").should == 0.5
  end
  
  it "should compute the probability of a set of tokens to be in a given class" do
    @bayes.stub!(:probability_of_token_in_class).and_return(0.9, 0.5, 0.8)
    expected = ((0.9 * 0.5 * 0.8) / ((0.9 * 0.5 * 0.8) + (0.1 * 0.5 * 0.2)))
    @bayes.probability_of_tokens_in_class(:klass, ['tokens', 'to', "check"]).should == expected
  end
  
  it "should compute the probability of a set of tokens to be in each class" do
    @bayes.stub!(:classes).and_return([:good,:bad,:ugly])
    @bayes.should_receive(:probability_of_tokens_in_class).with(:good, ['a', 'token']).and_return(0.7)
    @bayes.should_receive(:probability_of_tokens_in_class).with(:bad, ['a', 'token']).and_return(0.2)
    @bayes.should_receive(:probability_of_tokens_in_class).with(:ugly, ['a', 'token']).and_return(0.3)
    @bayes.bayesian_scores_for_tokens(['a', 'token']).should == {:good => 0.7, :bad => 0.2, :ugly => 0.3}
  end
  
  it "should optimize for a two class classifier" do
    @bayes.stub!(:classes).and_return([:good,:bad])
    @bayes.should_receive(:probability_of_tokens_in_class).with(:good, ['a', 'token']).and_return(0.7)
    @bayes.should_not_receive(:probability_of_tokens_in_class).with(:bad, ['a', 'token'])
    scores = @bayes.bayesian_scores_for_tokens(['a', 'token'])
    scores[:good].should be_close(0.7, 0.000001)
    scores[:bad].should be_close(0.3, 0.000001)
  end
  
end
