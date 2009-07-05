# encoding: UTF-8

module Decider
  class Token
    attr_reader :index
    attr_accessor :count
    
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
    
    def merge(other_token)
      assert_other_can_be_added(other_token)
      @count += other_token.count
    end
    
    def +(other_token)
      assert_other_can_be_added(other_token)
      combined_token = self.dup
      combined_token.count = @count + other_token.count
      combined_token
    end
    
    private
    
    def assert_other_can_be_added(other)
      unless other.respond_to?(:count)
        raise ArgumentError, "can't add #{other.to_s} to Token #{self.to_s}"
      end
    end
  end
end
