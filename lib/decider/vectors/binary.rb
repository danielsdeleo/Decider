# encoding: UTF-8

module Decider
  module Vectors
    class Binary < AbstractBase
      
      def initialize(token_index_hsh=nil)
        super
        @vector = Array.new(token_index_hsh.length, 0)
      end
      
      def to_a
        @vector
      end
      
      def duplicated
        @vector = @vector.dup
      end
      
      def convert_document(document)
        document.tokens.each do |t|
          if i = index_of[t]
            @vector[i] = 1
          end
        end
      end
      
      # For binary vectors, the Tanimoto coefficient is used.
      # http://en.wikipedia.org/wiki/Jaccard_index
      def closeness(other_vector)
        other = other_vector.to_a
        @vector.dot(other).to_f / ((other.dot(other) + @vector.dot(@vector) - @vector.dot(other)))
      end
      
      def average(other_vector)
        avg_vector = duplicate
        @vector.length.times do |i|
          avg_vector.to_a[i] = (@vector[i].to_i + other_vector.to_a[i].to_i ) / 2
        end
        avg_vector
      end
      
    end
  end
end
