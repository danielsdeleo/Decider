# encoding: UTF-8

module Decider
  class TokenSelector
    
    class BasePaths < Array
      
      def match_to(uri)
        self.map { |matcher| matcher.match(uri)}.compact
      end
      
      def <<(path)
        push(path.kind_of?(Regexp) ? path : Regexp.new(Regexp.escape(path)))
        self
      end
      
      private
      
      def push(*args)
        super(*args)
      end
      
    end
    
    attr_reader :base_paths
    
    def initialize
      @base_paths = BasePaths.new
    end
    
    def parameters(uri)
      remove_base_paths(uri).split(/(?:\&|\?|\\\\|\\|\/\/|\/|\=|\[|\]|\.\.|\.)/)
    end
    
    def ngrams(uri, opts={})
      parameters(uri).map { |parms| extract_ngrams(parms, opts) }.flatten
    end
    
    def remove_base_paths(uri)
      results = @base_paths.match_to(uri).map { |match| match.post_match }
      results.empty? ? uri : select_best_result_from(results)
    end
    
    def select_best_result_from(results)
      results.inject { |shortest, current| current.length < shortest.length ? current : shortest }
    end
    
    def extract_ngrams(word, opts={})
      ngrams = []
      ngram_size = opts[:n] || 2
      (word.length - ngram_size + 1).times do |i|
        ngrams << word[i, ngram_size]
      end
      ngrams
    end
    
  end
end
