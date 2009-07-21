# encoding: UTF-8

module Decider
  class Document
  #  class Doc
    include TokenTransforms

    class << self
      def custom_transforms(transforms_module)
        include transforms_module
      end
    end

    attr_reader :raw, :additional_tokens, :training_set
    attr_writer :domain_tokens

    def initialize(raw_text)
      @raw = raw_text
      @domain_tokens, @additional_tokens = [], []
    end

    def push_additional_tokens(tokens)
      @additional_tokens += tokens
    end
    
    # returns domain tokens if given no argument. If given an argument, sets 
    # domain tokens. This allows you to avoid using <tt>self.domain_tokens = [...]</tt>
    # when writing token transform modules.
    def domain_tokens(new_domain_tokens=nil)
      if new_domain_tokens
        @domain_tokens = new_domain_tokens
      else
        @domain_tokens
      end
    end

    def tokens
      (@domain_tokens + @additional_tokens)
    end

  end
    
  #end
end
