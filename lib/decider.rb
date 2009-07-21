# encoding: UTF-8

require "stemmer"

unless defined?(DECIDER_ROOT)
  DECIDER_ROOT = File.dirname(__FILE__) + '/'
end

require DECIDER_ROOT + "decider/cache_invalidation"
require DECIDER_ROOT + "decider/token"
require DECIDER_ROOT + "decider/core_extensions"
require DECIDER_ROOT + "decider/stopwords"
require DECIDER_ROOT + "decider/token_transforms"
require DECIDER_ROOT + "decider/document"
require DECIDER_ROOT + "decider/document_helper"
require DECIDER_ROOT + "decider/training_set"
require DECIDER_ROOT + "decider/classifiers/base"
require DECIDER_ROOT + "decider/classifiers/bayes"
require DECIDER_ROOT + "decider/classifiers/anomaly"

module Decider
  extend self
  
  # Convenience method for Classifier.new
  def classifier(*args, &block)
    Classifier.new(*args, &block)
  end
end

