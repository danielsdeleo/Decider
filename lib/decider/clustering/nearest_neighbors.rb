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
      def k_nearest_neighbors(k, document, opts={})
        tree.knn(k, vector(new_document(:query_target, document)), opts)
      end
      
      alias :knn :k_nearest_neighbors
      
      # Unoptimized KNN search that does not use BK Trees. This is the only
      # way to do a KNN search with a distance function that doesn't form a 
      # metric space, such as Vectors::BinaryRecommendation#distance
      #
      # The name of this method is a warning.
      def slow_knn(k, document)
        results = {}
        target_vector = vector(new_document(:query_target, document))
        corpus.documents.each do |doc|
          vector = vector(doc)
          results[doc] = target_vector.distance(vector)
        end
        select_best_results(k, results)
      end
      
      private
      
      def select_best_results(n, results_hash)
        return results_hash.keys if results_hash.size <= n
        scores = results_hash.values.sort!
        best_scores = scores[Range.new(0, (n - 1))]
        #puts "best scores: " + best_scores.join(",")
        results_hash.select { |result, score| best_scores.include?(score) && best_scores.remove(score) }.map do |result_and_score|
          result_and_score.first
        end
      end
      
    end
  end
end
