# encoding: UTF-8

module Decider
  module Vectors
    class Binary < AbstractBase
      
      class << self
        def prototype(token_index_hsh)
          prototype = self.new(token_index_hsh)
          def prototype.new(document)
            new_vector = self.dup
            new_vector.duplicated
            new_vector.convert_document(document)
            new_vector
          end
          prototype
        end
      end
      
      attr_reader :index_of
      
      def initialize(token_index_hsh=nil)
        @index_of = token_index_hsh
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
      
    end
  end
end
