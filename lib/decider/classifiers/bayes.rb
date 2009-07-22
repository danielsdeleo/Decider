# encoding: UTF-8

module Decider
  module Classifier
    class Bayes < Base
      
      # Classifies +document_text+ based on previous training.
      def classify(document_text)
        scores(document_text).inject { |memo, key_val| key_val.last > memo.last ? key_val : memo }.first
      end
    
      # Gives the probabilites for +document_text+ to be in each class.
      def scores(document_text)
        bayesian_scores_for_tokens(new_document(document_text).tokens)
      end
    
      def bayesian_scores_for_tokens(tokens)
        result = {}
        if classes.count == 2
          class_name, other_class = class_names
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
        loop_index = 1
        #p "START============================================================="
        tokens.each do |token|
          loop_index = (loop_index + 1) % 10
          probability = probability_of_token_in_class(klass, token)
          product = product * probability
          inverse_product = inverse_product * (1 - probability)
          #p "interim numerator: #{product}"
          #p "interim denominator: #{(product + inverse_product)}"
          if loop_index == 0
            #p "rebalancing..."
            product, inverse_product = rebalance!(product, inverse_product) 
            #p "interim numerator: #{product}"
            #p "interim denominator: #{(product + inverse_product)}"
          end
        end
        #p "FIN=============================================================="
        product / (product + inverse_product)
      end
    
      def scores_of_all_documents
        unless @scores_of_all_documents
          @scores_of_all_documents = Hash.new {|hsh,key| hsh[key]=[]}
          classes.each do |class_name, training_set|
            training_set.documents.each do |doc|
              bayesian_scores_for_tokens(doc.tokens).each do |klass_name, score|
                @scores_of_all_documents[klass_name] << score
              end
            end
          end
        end
        @scores_of_all_documents
      end
    
      # Computes the probability of +token+ appearing in +klass+ as follows:
      #
      # (appearances_in_class/ number_of_docs_in_class)
      # -----------------------------------------
      # (appearances_in_class/ number_of_docs_in_class) + (other_apperances / number_of_other_documents)
      def probability_of_token_in_class(klass, token)
        @probability_of_token_in_class ||= token_probability_bf
        unless @probability_of_token_in_class[[klass, token].hash.to_s]
          occurrences = occurrences_of_token_in_class(klass, token)
          doc_counts = document_counts_by_class(klass)
          this_class_ratio = ((occurrences[:this] || 0).to_f / (doc_counts[:this] || 1))
          other_classes_ratio = ((occurrences[:other] || 0).to_f  / (doc_counts[:other] || 1))
          probability = bounded_probability(this_class_ratio, other_classes_ratio)
          @probability_of_token_in_class[[klass,token].hash.to_s] = probability
        end
        @probability_of_token_in_class[[klass,token].hash.to_s]
        #p "probability of token in class #{r}"
        #r
      end
    
      def document_counts_by_class(klass)
        @document_counts_by_class ||= {}
        unless @document_counts_by_class[klass]
          doc_counts = Hash.new(0)
          classes.each do |class_name, training_set|
            if class_name == klass
              doc_counts[:this] = training_set.doc_count
            else
              doc_counts[:other] += training_set.doc_count
            end
          end
          @document_counts_by_class[klass] = doc_counts.map_vals do |doc_count|
            doc_count == 0 ? 1 : doc_count
          end
        end
        @document_counts_by_class[klass]
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
      
      def total_documents
        total_docs = 0
        classes.each do |class_name, training_set|
          total_docs += training_set.doc_count
        end
        total_docs
      end
      
      def invalidate_cache
        super
        @occurrences_of_token_in_class = nil
        @document_counts_by_class = nil
        @scores_of_all_documents = nil
        @probability_of_token_in_class = nil
      end
      
      private
      
      def rebalance!(product, inverse_product)
        return [1.0, (inverse_product / product)]
      end
      
      def bounded_probability(this, other)
        # default value for unknown tokens
        return 0.5 if this == 0.0 && other == 0.0
        probability = (this / (this + other))
        if probability > 0.99
          return 0.99
        elsif probability < 0.01
          return 0.01
        else
          return probability
        end
      end
      
      def token_probability_bf
        #k = (total_documents * 1 * 0.7).round + 1
        #BloomFilter.new(15, k, rand(2 ** 32))
        {}
      end
      
    end
  end
end
