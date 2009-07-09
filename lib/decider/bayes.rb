# encoding: UTF-8

module Decider
  module Bayes
    
    def probabilities_for_tokens(tokens)
      result = Hash.new(0)
      tokens.each do |token|
        probabilities_for_token(token).each do |klass, probability|
          result[klass] += probability
        end
      end
      result
    end
    
    def probabilities_for_token(token)
      term_frequencies = term_frequency_for_token(token)
      total_appearances = term_frequencies.inject(0) { |sum, key_val| sum + key_val.last }
      result = {}
      total_appearances = 1 if total_appearances == 0
      term_frequencies.each do |klass, count|
        result[klass] = count.to_f / total_appearances.to_f
      end
      result
    end
    
    def term_frequency_for_token(token)
      result = {}
      classes.each do |class_name, training_set|
        result[class_name] = training_set.term_frequency[token] || 0
      end
      result
    end
    
  end
end
