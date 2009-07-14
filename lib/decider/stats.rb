# encoding: UTF-8

module Decider
  module Stats
    
    # TODO: caching
    def avg_scores
      scores_of_all_documents.map_vals do |scores|
        Math.avg(scores)
      end
    end
    
    # TODO: caching
    def stddevs
      scores_of_all_documents.map_vals do |scores|
        Math.stddev(scores)
      end
    end
    
    def anomaly_score(document)
      document_scores = scores(document)
      anomaly_scores = {}
      avg_scores.each do |class_name, average|
        anomaly_scores[class_name] = (average - document_scores[class_name]) / stddevs[class_name]
      end
      anomaly_scores
    end
    
  end
end
