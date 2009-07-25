# encoding: UTF-8

module Decider
  module Classifier
    class NotImplementedError < StandardError
    end
    
    class Base
      attr_reader :algorithm, :classes, :name, :store
    
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
        @classes = {}
        self.document_callback = block if block_given?
        classes.each do |klass|
          @classes[klass.to_sym] = TrainingSet.new(klass, self, &document_callback)
          define_accessor_for(klass)
          define_predicate_for(klass)
        end
      end
    
      # Gives the names of the document classes defined in the constructor.
      def class_names
        @classes.keys
      end
      
      # Sort the TrainingSets (classes) by name. Converting documents to vectors
      # (see Vectorize) depends on getting the training sets in a deterministic
      # ordering. If everyone would just use Ruby 1.9, I wouldn't have to do this...
      # jerks!
      def sorted_classes
        @sorted_classes ||= class_names.sort.map { |name| @classes[name] }
      end
      
      def classify(*args)
        raise NotImplementedError, "#classify is supposed to be defined in a subclass"
      end
      
      # Just a stub here. Called by the training set(s) when a new document is 
      # added. Subclasses use this to nillify cached computations
      def invalidate_cache
      end
      
      def save_as(name)
        @name = name.to_s
        self
      end
      
      def to(back_end, *opts)
        store_name = "moneta/" + back_end.to_s
        require store_name
        @store = store_name.to_const.new(*opts)
      end
      
      def save
        @classes.each_value { |ts| ts.save }
      end
      
      def load
        @classes.each_value { |ts| ts.load }
      end
      
      alias :save_to :to
      
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
