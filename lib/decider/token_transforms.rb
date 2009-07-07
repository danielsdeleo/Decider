# encoding: UTF-8

module Decider
  module TokenTransforms
    
    def plain_text
      domain_tokens(raw.split(/(?:[\s]|\.|\,|\;|\:|"|')+/))
    end
    
    def uri
      domain_tokens(raw.split(/(?:\&|\?|\\\\|\\|\/\/|\/|\=|\[|\]|\.\.|\.)/))
    end
    
    def character_ngrams(opts={:n=>2})
      ngrams_per_token = domain_tokens.map { |token| extract_ngrams(token, opts) }
      push_additional_tokens(ngrams_per_token.flatten)
    end
    
    def ngrams(opts={:n=>2})
      token_ngrams = extract_ngrams(domain_tokens, opts).map { |n| n.join(" ")}  
      push_additional_tokens(token_ngrams)
    end
    
    def stem
      domain_tokens.map! { |t| t.stem }
    end
    
    def remove_stopwords(stopword_list="ENGLISH_US")
      tokens_sans_stopwords = []
      stopword_list = Stopwords.const_get(stopword_list)
      domain_tokens.each do |token| 
        tokens_sans_stopwords << token unless stopword_list.include?(token)
      end
      domain_tokens(tokens_sans_stopwords)
    end
    
    private
    
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
