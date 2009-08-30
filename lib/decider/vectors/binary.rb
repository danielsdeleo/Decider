# encoding: UTF-8

module Decider
  module Vectors
    class Binary < AbstractBase
      attr_accessor :vector
      
      # For binary vectors, the Tanimoto coefficient is used.
      # http://en.wikipedia.org/wiki/Jaccard_index
      similarities do |other_vector|
        other = other_vector.to_a
        @vector.dot(other).to_f / ((other.dot(other) + @vector.dot(@vector) - @vector.dot(other)))
      end
      
      distances do |other_vector|
        #@vector.length - @vector.dot(other_vector.to_a)
        distance = 0
        @vector.length.times do |i|
          distance += 1 if @vector[i].to_i != other_vector.to_a[i].to_i
        end
        distance
      end
      
      averages do |other_vector|
        avg_vector = duplicate
        @vector.length.times do |i|
          avg_vector.to_a[i] = (@vector[i].to_i + other_vector.to_a[i].to_i ) / 2
        end
        avg_vector
      end
      
      class << self
        # Creates a new binary vector from the given array. This is used to
        # facilitate testing.
        def from_array(ary)
          v = self.new({})
          v.vector = ary
          v
        end
      end
      
      def initialize(token_index_hsh=nil)
        super
        @vector = Array.new(token_index_hsh.length, 0)
      end
      
      def convert_document(document)
        document.tokens.each do |t|
          if i = index_of[t]
            @vector[i] = 1
          end
        end
      end
      
    end
  end
end
