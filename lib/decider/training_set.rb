# encoding: UTF-8

module Decider
  class TrainingSet
    attr_reader :documents #, :new_document_callback
    include DocumentHelper
    
    # Creates a new training set. Generally, one training set object corresponds
    # to a single class of document, i.e., spam or ham.
    # Documents given for training (<<) or analysis
    # will be processed according to the given block. For example:
    # 
    #   ts = TrainingSet.new do |doc|
    #     doc.plain_text
    #     doc.stem
    #     doc.ngrams(3)
    #   end
    #
    # The methods called on doc are defined in TokenTransforms. Your own
    # tokenization methods can be created in a module and loaded with 
    # <tt>Document.custom_transforms(YourOwnTokenTransforms)</tt>
    #
    def initialize(owner, &block)
      @owner = owner
      @tokens, @documents = {}, []
      if block_given?
        self.document_callback = block
      end
    end
    
    def tokenize(&block)
      self.document_callback= block
    end
    
    # Uses +document_string+ as a training document
    def <<(document_string)
      invalidate_cache
      
      doc = new_document(document_string)
      @documents << doc
      
      doc.tokens.each do |token|
        if @tokens.has_key?(token)
          @tokens[token].increment
        else
          @tokens[token] = Token.new(token, :index => @tokens.length)
        end
      end
      self
    end
    
    def tokens
      @token_values ||= @tokens.keys
    end
    
    def term_frequency
      term_frequency = {}
      tokens.each { |token| term_frequency[token] = count_of(token) }
      term_frequency
    end
    
    def count_of(token)
      @tokens[token].count
    end
    
    def doc_count
      @documents.count
    end
    
    private
    
    def hapax_occurrence_value
      0
    end
    
    def invalidate_cache
      @owner.invalidate_cache
      @token_values = nil
    end
    
  end
  
end
