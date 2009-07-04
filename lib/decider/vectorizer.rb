# encoding: UTF-8

module Decider
  class Vectorizer
    attr_reader :tokens
    
    def initialize
      @tokens = []
    end
    
    def index_of(token)
      @tokens.index(token)
    end
    
    def vectorize(tokens)
      vector = Array.new(@tokens.length, 0)
      tokens.each { |token| vector[index_of(token)] = 1 }
      vector
    end
  end
end
