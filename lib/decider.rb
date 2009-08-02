# encoding: UTF-8

require "stemmer"
#require "bloomfilter" # igrigorik-bloomfilter-0.1.1 (1.8.x) || rjspotter-bloomfilter (1.9.x)
require "moneta"

unless defined?(DECIDER_ROOT)
  DECIDER_ROOT = File.dirname(__FILE__) + '/'
end

require DECIDER_ROOT + "decider/errors"
require DECIDER_ROOT + "decider/core_extensions"
require DECIDER_ROOT + "decider/vectors/abstract_base"
require DECIDER_ROOT + "decider/vectors/binary"
require DECIDER_ROOT + "decider/vectors/sparse_binary"
require DECIDER_ROOT + "decider/stopwords"
require DECIDER_ROOT + "decider/token_transforms"
require DECIDER_ROOT + "decider/document"
require DECIDER_ROOT + "decider/document_helper"
require DECIDER_ROOT + "decider/vectorize"
require DECIDER_ROOT + "decider/training_set"
require DECIDER_ROOT + "decider/classifiers/base"
require DECIDER_ROOT + "decider/classifiers/bayes"
require DECIDER_ROOT + "decider/classifiers/anomaly"
require DECIDER_ROOT + "decider/clustering/bk_tree"
require DECIDER_ROOT + "decider/clustering/node"
require DECIDER_ROOT + "decider/clustering/base"

module Decider
  
  extend self
  
  # Convenience method for Classifier::Bayes.new
  def classifier(*args, &block)
    Classifier::Bayes.new(*args, &block)
  end
end
