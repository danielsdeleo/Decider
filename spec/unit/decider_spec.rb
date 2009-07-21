# encoding: UTF-8

require File.dirname(__FILE__) + '/../spec_helper'

describe Decider do
  
  it "should provide convenient access to Classifier.new" do
    Classifier::Bayes.should_receive(:new).with(:spammy, :hammy)
    Decider.classifier(:spammy, :hammy)
  end
  
end