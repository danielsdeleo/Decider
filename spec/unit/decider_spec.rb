# encoding: UTF-8

require File.dirname(__FILE__) + '/../spec_helper'

describe Decider do
  
  it "should provide convenient access to Classifier.new" do
    Classifier.should_receive(:new).with(:bayes, :spammy, :hammy)
    Decider.classifier(:bayes, :spammy, :hammy)
  end
  
end