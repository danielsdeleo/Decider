# encoding: UTF-8

require "stemmer"
#require "bloomfilter" # igrigorik-bloomfilter-0.1.1 (1.8.x) || rjspotter-bloomfilter (1.9.x)
require "moneta"

unless defined?(DECIDER_ROOT)
  DECIDER_ROOT = File.dirname(__FILE__) + '/decider/'
end

require DECIDER_ROOT + "errors"
require DECIDER_ROOT + "core_extensions"
require DECIDER_ROOT + "vectors/abstract_base"
require DECIDER_ROOT + "vectors/binary"
require DECIDER_ROOT + "vectors/sparse_binary"
require DECIDER_ROOT + "stopwords"
require DECIDER_ROOT + "token_transforms"
require DECIDER_ROOT + "document"
require DECIDER_ROOT + "document_helper"
require DECIDER_ROOT + "vectorize"
require DECIDER_ROOT + "training_set"
require DECIDER_ROOT + "clustering/bk_tree"
require DECIDER_ROOT + "clustering/node"
require DECIDER_ROOT + "clustering/base"
require DECIDER_ROOT + "clustering/hierarchical"
require DECIDER_ROOT + "clustering/nearest_neighbors"
require DECIDER_ROOT + "classifiers/base"
require DECIDER_ROOT + "classifiers/bayes"
require DECIDER_ROOT + "classifiers/anomaly"
require DECIDER_ROOT + "classifiers/nearest_neighbors"

module Decider
  
  extend self
  
  # Convenience method for Classifier::Bayes.new
  def classifier(*args, &block)
    Classifier::Bayes.new(*args, &block)
  end
end
