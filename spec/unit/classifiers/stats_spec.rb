# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"

class StatsSpecTestHarness
  include Stats
end

describe Stats do
  
  before(:each) do
    @stats = StatsSpecTestHarness.new
  end
  
  it "should compute the average score of the documents in each class" do
    @stats.should_receive(:scores_of_all_documents).and_return({:cool=>[0.9,0.85,0.95], :lame=>[0.1,0.15,0.05]})
    result = @stats.avg_scores
    result[:cool].should be_close(0.9, 0.000001)
    result[:lame].should be_close(0.1, 0.000001)
  end
  
  it "should compute the standard deviation of the scores of the training docs" do
    @stats.should_receive(:scores_of_all_documents).and_return({:cool=>[0.9,0.85,0.95], :lame=>[0.1,0.15,0.05]})
    result = @stats.stddevs
    result[:cool].should be_close(0.04082, 0.00001)
  end
  
  it "should compute the number of standard deviations from the mean for a document" do
    @stats.stub!(:scores).and_return(:one_class => 0.75)
    @stats.stub!(:avg_scores).and_return(:one_class => 0.85)
    @stats.stub!(:stddevs).and_return(:one_class => 0.05)
    @stats.anomaly_score("an innocuous document")[:one_class].should be_close(2.0, 0.00001)
  end
  
end
