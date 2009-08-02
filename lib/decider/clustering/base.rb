# encoding: UTF-8

module Decider
  module Clustering
    class Base
      attr_reader :classes, :name, :store
      
      include Vectorize
      include DocumentHelper
      
      def initialize(vector_type=nil, &block)
        @vector_class = ("decider/vectors/" + (vector_type ? vector_type.to_s : "sparse_binary")).to_const
        self.document_callback = block if block_given?
        @classes = {:corpus => TrainingSet.new(:corpus, self, &document_callback) }
      end
      
      def <<(document)
        corpus << document
      end
      
      def push(*args)
        corpus.push(*args)
      end
      
      def sorted_classes
        [corpus]
      end
      
      def vector_class
        @vector_class
      end
      
      def invalidate_cache
        super
      end
      
      def corpus
        @classes[:corpus]
      end
      
    end
  end
end
