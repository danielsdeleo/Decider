# encoding: UTF-8

module Decider
  class TrainingSet
    
    def initialize
      @tokens = {}
    end
    
    def <<(token)
      invalidate_cache
      
      if @tokens.has_key?(token)
        @tokens[token].increment
      else
        @tokens[token] = Token.new(token, :index => @tokens.length)
      end
      self
    end
    
    def tokens
      @tokens.keys
    end
    
    def index_of(token)
      @tokens[token].index
    end
    
    def count_of(token)
      @tokens[token].count
    end
    
    def vectorize(tokens)
      vector = Array.new(@tokens.length, 0)
      tokens.each { |token| vector[index_of(token)] = 1 }
      vector
    end
    
    def total_tokens
      @token_count ||= @tokens.inject(0) { |sum, key_val| sum += key_val.last.count }
    end
    
    private
    
    def invalidate_cache
      @token_count = nil
    end
    
    public
    
    class Token
      attr_reader :index, :count
      
      def initialize(token_str, opts={})
        @token_str = token_str
        @index = opts[:index]
        @count = 1
      end
      
      def increment
        @count += 1
      end
      
      def to_s
        @token_str
      end
    end
    
  end
end
