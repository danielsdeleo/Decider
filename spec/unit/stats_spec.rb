# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

class StatsSpecTestHarness
  include Stats
end

describe Stats do
  
  before(:each) do
    @stats = StatsSpecTestHarness.new
  end
  
end
