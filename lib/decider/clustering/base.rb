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
      
      def push(*args)
        corpus.push(*args)
      end
      
      def sorted_classes
        [corpus]
      end
      
      def tree
        unless @tree
          @tree = Tree.new
          corpus.documents.each do |doc|
            @tree.insert(:name_tbd, binary_vector(doc))
          end
        end
        @tree
      end
      
      def root_node
        tree.root
      end
      
      def invalidate_cache
        @tree = nil
        super
      end
      
      def corpus
        @classes[:corpus]
      end
      
    end
  end
end
