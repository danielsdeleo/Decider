# encoding: UTF-8

module Decider
  module Clustering
    class Hierarchical < Base
      
      def tree
        unless @tree
          @tree = Tree.new
          corpus.documents.each do |doc|
            @tree.insert(doc.name, vector(doc))
          end
        end
        @tree
      end
      
      def vectors
        vectors = {}
        corpus.documents.each do |doc|
          vectors[doc.name] = vector(doc)
        end
        vectors
      end
      
      def root_node
        tree.root
      end
      
      def invalidate_cache
        @tree = nil
        super
      end
      
    end
  end
end
