# encoding: UTF-8

module Decider
  module Vectors
    class SparseBinary < AbstractBase
      attr_accessor :vector_size
      
      # For binary vectors, the Tanimoto coefficient is used.
      # http://en.wikipedia.org/wiki/Jaccard_index
      similarities do |other|
        # unoptimized implementation:
        # items_in_both = (@vector & other.vector).size
        # items_in_self_only = (@vector - other.vector).length
        # items_in_other_only = (other.vector - @vector).length
        # items_in_both.to_f / (items_in_both + items_in_self_only + items_in_other_only)
        if self == other
          1.0
        else
          items_in_both = (@vector & other.vector).size
          items_in_both.to_f / (vector_size + other.vector_size - items_in_both)
        end
      end
      
      distances do |other|
        return 0 if self == other
        (@vector - other.vector).length + (other.vector - @vector).length
      end
      
      averages do |other|
        new_vector = duplicate
        new_vector.vector = @vector & other.vector
        new_vector
      end
      
      def to_a
        vector = Array.new(token_indices.length, 0)
        @vector.each do |index|
          vector[index] = 1
        end
        vector
      end
      
      def convert_document(document)
        document.tokens.each do |t|
          if i = index_of[t]
            @vector << i
          end
        end
        @vector_size ||= @vector.size
      end
      
    end
  end
end
