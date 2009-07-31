# encoding: UTF-8

module Decider
  module TokenTransforms
    
    class << self
      
      def default_transform
        lambda do |doc|
          doc.plain_text
          doc.stem
        end
      end
      
    end
    
    # Assigns the value passed to the document's constructor to domain_tokens.
    # If you have documents that are already in array form, use this.
    # ex:
    #   doc = Document.new(:already_a_list, %w{a list of tokens})
    #   doc.verbatim
    #   doc.domain_tokens #=> ['a', 'list', 'of', 'tokens']
    def verbatim
      domain_tokens(raw)
    end
    
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
    def character_ngrams(size=2)
      ngrams_per_token = domain_tokens.map { |token| extract_ngrams(token, size) }
      push_additional_tokens(ngrams_per_token.flatten)
    end
    
    # Creates additional tokens by combining existing ones into ngrams
    # for example(with <tt>:n => 2</tt>), the tokens "foo bar baz" would give
    # the ngrams <tt>["foo bar", "bar baz"]</tt>
    def ngrams(size=2)
      token_ngrams = extract_ngrams(domain_tokens, size).map { |n| n.join(" ")}
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
    
    def extract_ngrams(strings, ngram_sizes=2)
      ngram_sizes = ngram_sizes.respond_to?(:each) ? ngram_sizes : [ngram_sizes]
      
      ngrams = []
      ngram_sizes.each do |ngram_size|
        (strings.length - ngram_size + 1).times do |i|
          ngrams << strings[i, ngram_size]
        end
      end
      ngrams
    end
    
  end
  
end
