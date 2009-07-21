# encoding: UTF-8

module Decider
  module Classifier
    class Base
      attr_reader :algorithm, :classes
    
      include DocumentHelper
    
      # Creates a new classifier of type +algorithm+ with one or more classes.
      # Currently, only a Bayesian algorithm is implemented, so the +algorithm+
      # term is actually meaningless.
      # Symbols are preferred for class names.
      # The optional block controls how documents get tokenized. The default
      # tokenization strategy is to split tokens on whitespace or . , ; : " ' and ?
      # characters, and then stem the results. See Document and TokenTransforms for
      # more detail.
      # To manually set a new classifier to use the defaults, you would create a
      # classifier like so:
      #
      #   classifier = Classifier.new(:bayes, :spam, :ham) do |doc|
      #     doc.plain_text
      #     doc.stem
      #   end
      #
      # You can create your own tokenization strategies in a module and use
      # Document.custom_transforms(MyTokenTransforms) to have it included.
      # 
      # Once you have created a classifier, you train it like so (continuing the
      # above example):
      #
      #   # document classes magically defined as methods:
      #   classifier.spam << "spammy viagra phishing blah blah BUY NOW!!! FREE!!"
      #   classifier.ham << "something you actually want to read"
      #
      # The values returned by +spam+ and +ham+ in the above example are instances 
      # of the TrainingSet class.
      # 
      # You also get predicate (?) methods, like this:
      #
      #   classifier.spam?("BUY CHEAP FAKE VIAGRA NOW AND WATCH YOUR CREDIT DIE!!")
      #   => true
      #
      def initialize(*classes, &block)
        @algorithm = algorithm
        @classes = {}
        self.document_callback = block if block_given?
        classes.each do |klass|
          @classes[klass.to_sym] = TrainingSet.new(&document_callback)
          define_accessor_for(klass)
          define_predicate_for(klass)
        end
      end
    
      # Gives the names of the document classes defined in the constructor.
      def class_names
        @classes.keys
      end
    
      # Gives the probabilites for +document_text+ to be in each class.
      def scores(document_text)
        bayesian_scores_for_tokens(new_document(document_text).tokens)
      end
    
      # TODO: Caching
      def scores_of_all_documents
        result = Hash.new {|hsh,key| hsh[key]=[]}
        classes.each do |class_name, training_set|
          training_set.documents.each do |doc|
            bayesian_scores_for_tokens(doc.tokens).each do |klass_name, score|
              result[klass_name] << score
            end
          end
        end
        result
      end
    
      # Classifies +document_text+ based on previous training.
      def classify(document_text)
        scores(document_text).inject { |memo, key_val| key_val.last > memo.last ? key_val : memo }.first
      end
    
      # Single-class classifiers have experimental anomaly detection. If +document_text+
      # is 3+ Standard Deviations from what the classifier thinks is "normal", returns
      # true, otherwise false
      def anomalous?(document_text)
        raise "I don't do anomaly detection on more than one class right now" if @classes.count > 1
        @classes.values.first.anomaly_score_of_document(document_text) > 3
      end
    
      private
    
      def define_accessor_for(klass)
        singleton_class = class << self; self; end 
        singleton_class.send :define_method, klass do
          @classes[klass]
        end
      end
    
      def define_predicate_for(klass)
        singleton_class = class << self; self; end 
        singleton_class.send :define_method, (klass.to_s + "?").to_sym do |text|
          classify(text) == klass
        end
      end
      
    end
  end
end
