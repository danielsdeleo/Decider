# encoding: UTF-8

module Decider
  module Classifier
    class Anomaly < Bayes
    
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
    
      # Single-class classifiers have experimental anomaly detection. If +document_text+
      # is 3+ Standard Deviations from what the classifier thinks is "normal", returns
      # true, otherwise false
      def anomalous?(document_text)
        raise "I don't do anomaly detection on more than one class right now" if @classes.count > 1
        @classes.values.first.anomaly_score_of_document(document_text) > 3
      end
    
    end
  end
end
