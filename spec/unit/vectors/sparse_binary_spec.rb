# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"
require File.dirname(__FILE__) + "/binary_vector_behavior"

describe Vectors::SparseBinary do
  
  before do
    @vector_class = Vectors::SparseBinary
  end
  
  it_should_behave_like "a binary vector"
end
