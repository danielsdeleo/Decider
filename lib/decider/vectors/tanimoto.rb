# encoding: UTF-8

module Decider
  module Vectors
    class Tanimoto < SparseBinary
      
      # Gives a distance measurement of 100_000 * (1 - tanimoto_coefficient(other))
      #
      # Defined normally instead of through the (metaprogramming) macro 
      # distances(&block) so we don't cache these values but use the cache for
      # #similarity instead
      def distance(other)
        #items_in_both = (@sparse_vector & other.sparse_vector).length
        #items_in_self_only = (@sparse_vector - other.sparse_vector).length
        #items_in_other_only = (other.sparse_vector - @sparse_vector).length
        #100000.0 * (1.0 - (items_in_both.to_f / (items_in_both + items_in_self_only + items_in_other_only)))
        100_000.0 * (1.0 - similarity(other))
      end
      
    end
  end
end
