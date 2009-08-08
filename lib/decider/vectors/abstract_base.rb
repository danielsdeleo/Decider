# encoding: UTF-8

module Decider
  module Vectors
    
    # The Base Class for various vector types. Vectors use a prototypal
    # inheritance mechanism (like javascript). This is slightly more complicated
    # but it helps avoid using class variables and facilites performance
    # enhancements, such as duplicating arrays instead of creating new ones
    class AbstractBase
      
      class << self
        def prototype(token_index_hsh)
          prototype = self.new(token_index_hsh)
          def prototype.new(document)
            new_vector = self.duplicate
            new_vector.convert_document(document)
            new_vector
          end
          prototype
        end
      end
      
      attr_reader :index_of
      alias :token_indices :index_of
      
      def initialize(token_index_hsh=nil)
        @index_of = token_index_hsh
      end
      
      def duplicated
      end
      
      def closeness(other)
        raise NotImplementedError.new(self.class, :difference_coefficient)
      end
      
      def average(other)
        raise NotImplementedError.new(self.class, :average)
      end
      
      def convert_document
        raise NotImplementedError.new(self.class, :convert_document)
      end
      
      def duplicate
        new_vector = self.dup
        new_vector.duplicated
        new_vector
      end
      
    end
  end
end
