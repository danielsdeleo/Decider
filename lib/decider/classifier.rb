# encoding: UTF-8

module Decider
  class Classifier
    attr_reader :algorithm, :classes
    
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
    def initialize(algorithm, *classes, &block)
      @algorithm = algorithm
      @classes = {}
      classes.each do |klass|
        ts = block_given? ? TrainingSet.new(&block) : TrainingSet.new()
        @classes[klass.to_sym] = ts
        define_accessor_for(klass)
        define_predicate_for(klass)
      end
    end
    
    # Gives the names of the document classes defined in the constructor.
    def classes
      @classes.keys
    end
    
    # Classifies +document_text+ based on previous training.
    def classify(document_text)
      result = {}
      @classes.each do |name, training_set|
        result[name] = training_set.probability_of_document(document_text)
      end
      result.inject { |memo, key_val| key_val.last > memo.last ? key_val : memo }.first
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
