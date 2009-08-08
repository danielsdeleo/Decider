# encoding: UTF-8

module Decider
  module Vectors
    class SparseBinary < AbstractBase
      attr_accessor :sparse_vector
      
      def initialize(token_index_hsh=nil)
        super
        @sparse_vector = []
      end
      
      def duplicated
        @sparse_vector = @sparse_vector.dup
      end
      
      def to_a
        vector = Array.new(token_indices.length, 0)
        @sparse_vector.each do |index|
          vector[index] = 1
        end
        vector
      end
      
      def convert_document(document)
        document.tokens.each do |t|
          if i = index_of[t]
            @sparse_vector << i
          end
        end
      end
      
      # For binary vectors, the Tanimoto coefficient is used.
      # http://en.wikipedia.org/wiki/Jaccard_index
      def closeness(other)
        #other = other_vector.to_a
        #@vector.dot(other).to_f / ((other.dot(other) + @vector.dot(@vector) - @vector.dot(other)))
        items_in_both = (@sparse_vector & other.sparse_vector).length
        items_in_self_only = (@sparse_vector - other.sparse_vector).length
        items_in_other_only = (other.sparse_vector - @sparse_vector).length
        items_in_both.to_f / (items_in_both + items_in_self_only + items_in_other_only)
      end
      
      def distance(other)
        (@sparse_vector - other.sparse_vector).length + (other.sparse_vector - @sparse_vector).length
      end
      
      def average(other)
        new_sparse_vector_ary = @sparse_vector & other.sparse_vector
        new_vector = duplicate
        new_vector.sparse_vector = new_sparse_vector_ary
        new_vector
      end
      
    end
  end
end
