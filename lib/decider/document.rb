# encoding: UTF-8

module Decider
  
  class DocumentFinalized < DeciderError
  end
  
  # Documents store the raw text used to create them as well as tokens extracted
  # from that text. Documents are initialized with the raw text of a document
  # then (typically) "visited upon" by a block that performs whatever operations
  # are needed to extract tokens from the raw text.
  #
  # Document can be extended with any token extraction methods you like. Just
  # write your methods in a module and pass it as an argument to custom_transforms
  # 
  # For examples of extending Document with token extraction methods, look at
  # TokenTransforms
  class Document
    include TokenTransforms

    class << self
      
      # Provides a wrapper to include so you don't have to use send. Use this to
      # extend the Document class with your own tokenization strategies.
      def custom_transforms(transforms_module)
        include transforms_module
      end
    end

    attr_reader :name, :raw, :additional_tokens, :training_set
    attr_writer :domain_tokens

    def initialize(name, raw_text)
      @name, @raw = name.to_s, raw_text
      @domain_tokens, @additional_tokens = [], []
    end

    def push_additional_tokens(tokens)
      assert_not_finalized
      @additional_tokens += tokens
    end
    
    # returns domain tokens if given no argument. If given an argument, sets 
    # domain tokens. This allows you to avoid using <tt>self.domain_tokens = [...]</tt>
    # when writing token transform modules.
    def domain_tokens(new_domain_tokens=nil)
      assert_not_finalized
      if new_domain_tokens
        @domain_tokens = new_domain_tokens
      else
        @domain_tokens
      end
    end

    def tokens
      @tokens ||= (@domain_tokens + @additional_tokens)
    end
    
    
    def final
      tokens
      @raw, @domain_tokens, @additional_tokens = nil, nil, nil
      @finalized = true
    end
    
    private
    
    def assert_not_finalized
      raise DocumentFinalized, "tokens can't be set or accessed after document is finalized" if @finalized
    end

  end
    
end
