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
          prototype
        end
        
        def distances(&compute_distance)
          define_method(:compute_distance, compute_distance) 
          define_method(:distance) do |other|
            @distances.lookup(self, other) || 
            @distances.store( :vectors => [self,other],
                              :result  => compute_distance(other))
          end
        end
        
        def similarities(&compute_similarity)
          define_method(:compute_similarity, compute_similarity)
          define_method(:similarity) do |other|
            @similarities.lookup(self, other) || 
            @similarities.store( :vectors => [self,other],
                                 :result  => compute_similarity(other))
          end
        end
        
        def averages(&compute_average)
          define_method(:compute_average, compute_average)
          define_method(:average) do |other|
            @averages.lookup(self, other) || 
            @averages.store( :vectors => [self,other],
                            :result  => compute_average(other))
          end
        end
      end
      
      attr_reader :index_of
      alias :token_indices :index_of
      
      attr_reader :distances, :similarities, :averages
      attr_accessor :vector
      
      def initialize(token_index_hsh=nil)
        @index_of = token_index_hsh
        @vector = []
        @distances, @similarities, @averages = (0..2).map {ComputationCache.new}
      end

      def new(document)
        new_vector = self.duplicate
        new_vector.convert_document(document)
        new_vector
      end
      
      # Subclasses should override this method to duplicate any instance varibles
      # that aren't duplicated by shallow copy. "selective deep copy"
      def duplicated
        if defined?(@vector)
          @vector = @vector.dup
        end
      end
      
      def ==(other_vector)
        @vector == other_vector.vector
      end
      
      def similarity(other)
        raise NotImplementedError.new(self.class, :similarity)
      end
     
      def average(other)
        raise NotImplementedError.new(self.class, :average)
      end
      
      def distance(other)
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
      
      # Returns the array representation of the vector
      def to_a
        @vector
      end
      
      class ComputationCache
        
        def initialize
          @results = Moneta::Memory.new
        end
        
        def lookup(*args)
          @results[args] || @results[args.reverse!]
        end
        
        def store(opts={})
          @results[opts[:vectors]] = opts[:result]
        end
        
      end
      
    end
  end
end
