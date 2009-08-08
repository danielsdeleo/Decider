# encoding: UTF-8

module Decider
  module Clustering
    class NearestNeighbors < Base
      
      def tree
        unless @tree
          @tree = BkTree.new
          corpus.documents.each do |doc|
            @tree.insert(doc, vector(doc))
          end
        end
        @tree
      end
      
      def invalidate_cache
        @tree = nil
        super
      end
      
      # Finds all documents in the training set for which the distance between
      # the vector representation of the the document is within +range+ of the
      # given +document+
      def in_range(range, document)
        doc = new_document(:query_target, document)
        tree.nearest_neighbors(range, vector(doc))
      end
      
      # Finds the single closest matching document in the training set as determined
      # using vector distance calculations
      def nearest(document)
        doc = new_document(:query_target, document)
        tree.nearest_neighbor(vector(doc))
      end
      
      # Finds the +k+ Nearest Neighbors of the given +document+
      def k_nearest_neighbors(k, document)
        tree.knn(k, vector(new_document(:query_target, document)))
      end
      
      alias :knn :k_nearest_neighbors
      
    end
  end
end
