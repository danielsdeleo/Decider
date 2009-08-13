# encoding: UTF-8

module Decider
  module Vectors
    class Tanimoto < SparseBinary
      
      def distance(other_vector)
        1000.0 * ((1.0 - closeness(other_vector)) )
      end
      
    end
  end
end
