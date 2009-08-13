# encoding: UTF-8

module Decider
  module Vectors
    class BinaryRecommendation < SparseBinary
      
      # Uses what I'll call the "github distance." This is the number of items
      # in self that are NOT in +other_vector+. This has important consequences:
      #   # Unless vector_a == vector_b
      #   vector_a.distance(vector_b) != vector_b.distance(vector_a) 
      # For this reason, +distance()+ DOES NOT define a metric space, and so
      # CANNOT be used in a BK Tree
      def distance(other_vector)
        (@sparse_vector - other_vector.sparse_vector).size
      end
      
    end
  end
end
