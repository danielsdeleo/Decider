# encoding: UTF-8

require "stemmer"

unless defined?(DECIDER_ROOT)
  DECIDER_ROOT = File.dirname(__FILE__) + '/'
end

require DECIDER_ROOT + "/decider/token_selector"
require DECIDER_ROOT + "/decider/training_set"
require DECIDER_ROOT + "decider/token"
require DECIDER_ROOT + "decider/core_extensions"
require DECIDER_ROOT + "decider/stopwords"
require DECIDER_ROOT + "decider/token_transforms"
