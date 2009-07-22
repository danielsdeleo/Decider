# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"

describe Classifier::Bayes do
  
  before(:each) do
    @classifier = Classifier::Bayes.new(:deck, :weak)
  end
  
  context "counting token and document frequencies" do
    it "should give a term frequency hash for a token" do
      deck_ts = mock("deck training set")
      deck_ts.stub!(:term_frequency).and_return({:indie_rock => 10, :foreign_films => 7})
      weak_ts = mock("weak training set")
      weak_ts.stub!(:term_frequency).and_return({:foreign_films => 2, :pop_culture => 11})
      @classifier.stub!(:classes).and_return({:deck => deck_ts, :weak => weak_ts})
      @classifier.term_frequency_for_token(:foreign_films).should == {:deck => 7, :weak => 2}
      @classifier.term_frequency_for_token(:indie_rock).should == {:deck => 10, :weak => 0}
    end
  
    it "should split term frequencies into {:this => x, :other => y}" do
      @classifier.stub!(:term_frequency_for_token).and_return {{:good => 5, :bad => 7, :ugly => 13}.dup}
      @classifier.occurrences_of_token_in_class(:good, "a_token").should == {:this => 5, :other => 20}
      @classifier.occurrences_of_token_in_class(:bad, "a token").should == {:this => 7, :other => 18}
      @classifier.occurrences_of_token_in_class(:ugly, "a token").should == {:this => 13, :other => 12}
    end
  
    it "should give the document counts by class" do
      good_class = mock("good")
      good_class.stub!(:doc_count).and_return(5)
      bad_class = mock('bad')
      bad_class.stub!(:doc_count).and_return(7)
      ugly_class = mock('ugly')
      ugly_class.stub!(:doc_count).and_return(13)
      @classifier.stub!(:classes).and_return({:good => good_class, :bad => bad_class, :ugly => ugly_class})
      @classifier.document_counts_by_class(:good).should == {:this => 5, :other => 20}
      @classifier.document_counts_by_class(:bad).should == {:this => 7, :other => 18}
      @classifier.document_counts_by_class(:ugly).should == {:this => 13, :other => 12}
    end
  
    it "should use fallback values if a class has no documents" do
      good_class = mock("good")
      good_class.stub!(:doc_count).and_return(0)
      bad_class = mock('bad')
      bad_class.stub!(:doc_count).and_return(0)
      @classifier.stub!(:classes).and_return({:good => good_class, :bad => bad_class})
      @classifier.document_counts_by_class(:good).should == {:this => 1, :other => 1}
    end
  
    it "should compute the probabiltity of a token to be in a given class" do
      @classifier.stub!(:occurrences_of_token_in_class).and_return({:this => 15, :other => 20})
      @classifier.stub!(:document_counts_by_class).and_return({:this => 5, :other => 10})
      expected = (15.0 / 5.0) / ((15.0/ 5.0) + (20.0 / 10.0))
      @classifier.probability_of_token_in_class(:klass, "one token").should == expected
    end
  
    it "should fallback to a neutral value if the token hasn't been seen before" do
      @classifier.stub!(:occurrences_of_token_in_class).and_return({:this => 0, :other => 0})
      @classifier.stub!(:document_counts_by_class).and_return({:this => 1, :other => 1})
      @classifier.probability_of_token_in_class(:klass, "one token").should == 0.5
    end
  
    it "should compute the probability of a set of tokens to be in a given class" do
      @classifier.stub!(:probability_of_token_in_class).and_return(0.9, 0.5, 0.8)
      expected = ((0.9 * 0.5 * 0.8) / ((0.9 * 0.5 * 0.8) + (0.1 * 0.5 * 0.2)))
      @classifier.probability_of_tokens_in_class(:klass, ['tokens', 'to', "check"]).should == expected
    end
  
    it "should compute the probability of a set of tokens to be in each class" do
      @classifier.stub!(:classes).and_return([:good,:bad,:ugly])
      @classifier.should_receive(:probability_of_tokens_in_class).with(:good, ['a', 'token']).and_return(0.7)
      @classifier.should_receive(:probability_of_tokens_in_class).with(:bad, ['a', 'token']).and_return(0.2)
      @classifier.should_receive(:probability_of_tokens_in_class).with(:ugly, ['a', 'token']).and_return(0.3)
      @classifier.bayesian_scores_for_tokens(['a', 'token']).should == {:good => 0.7, :bad => 0.2, :ugly => 0.3}
    end
  
    it "should optimize for a two class classifier" do
      @classifier.stub!(:class_names).and_return([:good,:bad])
      @classifier.should_receive(:probability_of_tokens_in_class).with(:good, ['a', 'token']).and_return(0.7)
      @classifier.should_not_receive(:probability_of_tokens_in_class).with(:bad, ['a', 'token'])
      scores = @classifier.bayesian_scores_for_tokens(['a', 'token'])
      scores[:good].should be_close(0.7, 0.000001)
      scores[:bad].should be_close(0.3, 0.000001)
    end
  
    it "should give a reasonable default if a token hasn't been seen in a class" do
      @classifier.stub!(:occurrences_of_token_in_class).and_return({:other=>6347, :this=>nil})
      @classifier.stub!(:document_counts_by_class).and_return({:other=>3052})
      nil_doesnt_float = lambda {@classifier.probability_of_tokens_in_class(:some_class, "aToken")}
      nil_doesnt_float.should_not raise_error(TypeError)
    end
    
    it "should give the total number of documents" do
      @classifier.deck.stub!(:doc_count).and_return(5)
      @classifier.weak.stub!(:doc_count).and_return(7)
      @classifier.total_documents.should == 12
    end
    
    it "should rebalance the values in bayesian combination so they don't get rounded to 0" do
      product, inverse_product = 0.1, 0.9
      product_2, inverse_product_2 = @classifier.send(:rebalance!, product, inverse_product)
      product_2.should == 1.0
      inverse_product_2.should == 9.0
    end
    
    it "should force the value of probability_of_token_in_class to within 0.01 to 0.99" do
      @classifier.send(:bounded_probability, 0, 1).should == 0.01
      @classifier.send(:bounded_probability, 1, 0).should == 0.99
    end
  
  end
  
  context "classifying documents" do
    
    it "should classify documents" do
      @classifier.should_receive(:bayesian_scores_for_tokens).and_return({:weak => 1, :deck => 0})
      @classifier.classify("java php").should == :weak
    end
    
    it "should give the raw scores" do
      @classifier.should_receive(:bayesian_scores_for_tokens).and_return({:weak => 1, :deck => 0})
      @classifier.scores("java php").should == {:deck => 0, :weak => 1}
    end
    
    it "should give the scores of the documents in each class" do
      @classifier.deck << "two deck" << "documents"
      @classifier.weak << "and one weak one"
      @classifier.stub!(:bayesian_scores_for_tokens).and_return({:deck =>0.9, :weak => 0.1},
                                                                {:deck =>0.6,:weak => 0.4},
                                                                {:deck =>0.8,:weak => 0.2})
      expected = {:deck => [0.9, 0.6, 0.8], :weak => [0.1, 0.4, 0.2] }
      @classifier.scores_of_all_documents.should == expected
    end
  
  end
  
  
  
end
