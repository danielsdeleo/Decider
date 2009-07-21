# encoding: UTF-8

module Decider
  module Classifier
    class Bayes < Base
    
      def bayesian_scores_for_tokens(tokens)
        result = {}
        if classes.count == 2
          class_name, other_class = classes.keys
          result[class_name] = probability_of_tokens_in_class(class_name, tokens)
          result[other_class] = 1 - result[class_name]
        else
          classes.each do |class_name, training_set|
            result[class_name] = probability_of_tokens_in_class(class_name, tokens)
          end
        end
        result
      end
    
      # Gives the probabilities of the tokens appearing in the given class
      # using Bayes' theorem to combine the probabilities of each token.
      def probability_of_tokens_in_class(klass, tokens)
        product, inverse_product = 1, 1
        tokens.each do |token|
          probability = probability_of_token_in_class(klass, token)
          product = product * probability
          inverse_product = inverse_product * (1 - probability)
        end
        product / (product + inverse_product)
      end
    
      # Computes the probability of +token+ appearing in +klass+ as follows:
      #
      # (appearances_in_class/ number_of_docs_in_class)
      # -----------------------------------------
      # (appearances_in_class/ number_of_docs_in_class) + (other_apperances / number_of_other_documents)
      def probability_of_token_in_class(klass, token)
        occurrences = occurrences_of_token_in_class(klass, token)
        doc_counts = document_counts_by_class(klass)
        this_class_ratio = ((occurrences[:this] || 0).to_f / (doc_counts[:this] || 1))
        other_classes_ratio = ((occurrences[:other] || 0).to_f  / (doc_counts[:other] || 1))
        if this_class_ratio == 0.0 && other_classes_ratio == 0.0
          0.5
        else
          (this_class_ratio / (this_class_ratio + other_classes_ratio))
        end
      end
    
      def document_counts_by_class(klass)
        doc_counts = Hash.new(0)
        classes.each do |class_name, training_set|
          if class_name == klass
            doc_counts[:this] = training_set.doc_count
          else
            doc_counts[:other] += training_set.doc_count
          end
        end
        doc_counts.map_vals do |doc_count|
          doc_count == 0 ? 1 : doc_count
        end
      end
    
      def occurrences_of_token_in_class(klass, token)
        result = Hash.new(0)
        term_frequencies = term_frequency_for_token(token)
        result[:this] = term_frequencies.delete(klass)
        term_frequencies.each do |other_klass, count|
          result[:other] += count
        end
        result
      end
    
      def term_frequency_for_token(token)
        classes.map_vals do |training_set|
          training_set.term_frequency[token] || 0
        end
      end
      
    end
  end
end
