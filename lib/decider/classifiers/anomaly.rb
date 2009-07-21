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
    
      context "detecting anomalies with the statistical algorithm" do

        before do
          @classifier = Classifier::Anomaly.new(:normal)
        end

        it "should complain if asked to do anomaly detection and it has 2+ classes" do
          strange_request = lambda { Classifier::Anomaly.new(:bayes, :spam, :ham).anomalous?("text")}
          strange_request.should raise_error
        end

        it "should classify a document as anomalous the document has an anomaly score > 3" do
          @classifier.normal.should_receive(:anomaly_score_of_document).with("rubyist loving java").and_return(11)
          @classifier.anomalous?("rubyist loving java").should be_true
        end

      end

    end
  end
end
