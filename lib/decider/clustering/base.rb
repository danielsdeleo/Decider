# encoding: UTF-8

module Decider
  module Clustering
    class Base
      attr_reader :classes, :name, :store
      
      include Vectorize
      include DocumentHelper
      
      def initialize(&block)
        @classes = {}
        self.document_callback = block if block_given?
        @classes[:corpus] = TrainingSet.new(:corpus, self, &document_callback)
      end
      
      def <<(document)
        corpus << document
      end
      
      def invalidate_cache
        super
      end
      
      private
      
      def corpus
        @classes[:corpus]
      end
      
    end
  end
end
