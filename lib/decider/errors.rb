# encoding: UTF-8

module Decider
  
  class DeciderError < StandardError
  end
  
  class NotImplementedError < DeciderError
    def initialize(klass, method)
      super("#{klass.name} expects #{method.to_s} to be defined in subclasses")
    end
  end
  
end
