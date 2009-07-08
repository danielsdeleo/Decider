# encoding: UTF-8

module Decider
  module TokenTransforms
    
    # Splits the raw text of a document using { whitespace . , : ; " ' ? } as
    # the delimeter set.
    def plain_text
      domain_tokens(raw.split(/(?:[\s]|\.|\,|\;|\:|"|'|\?)+/))
    end
    
    # Splits the raw text of a document using { & \\ \ // / = [ ] .. .} as
    # the delimeter set
    def uri
      domain_tokens(raw.split(/(?:\&|\?|\\\\|\\|\/\/|\/|\=|\[|\]|\.\.|\.)/))
    end
    
    # Creates additional tokens from existing ones by extracting character
    # ngrams. For the token <tt>"cheese"</tt> this would give (with <tt>:n => 2</tt>): 
    # ["ch", "he", "ee", "es", "se"]
    # If used in conjunction with stemming, be aware that if you call stem first,
    # then the stems will be used for generating the ngrams.
    def character_ngrams(opts={:n=>2})
      ngrams_per_token = domain_tokens.map { |token| extract_ngrams(token, opts) }
      push_additional_tokens(ngrams_per_token.flatten)
    end
    
    # Creates additional tokens by combining existing ones into ngrams
    # for example(with <tt>:n => 2</tt>), the tokens "foo bar baz" would give
    # the ngrams <tt>["foo bar", "bar baz"]</tt>
    def ngrams(opts={:n=>2})
      token_ngrams = extract_ngrams(domain_tokens, opts).map { |n| n.join(" ")}  
      push_additional_tokens(token_ngrams)
    end
    
    # Stems tokens using the Porter stemming algorithm as implemented by the
    # stemmer gem
    def stem
      domain_tokens.map! { |t| t.stem }
    end
    
    # Removes Stopwords, such as the, to, a, an ...
    # The list of stopwords (Stopwords::ENGLISH_US) is quite large, so you might
    # need to reduce it for your own application. Create your own list by defining
    # it as a constant under Decider::Stopwords and passing its name (as a string)
    # as the argument.
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
