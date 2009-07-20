#!/usr/bin/env ruby
# encoding: UTF-8
require "logger"
require File.dirname(__FILE__) + '/bench_helper'

N = 10000
#N = 100

module TrainingSetBench
  include BenchHelper::Logging
  
  extend self
  
  def training_set_for_indexing_test
    log "loading training set ``word_list'' "
    training_set = Decider::TrainingSet.new
    IO.readlines(BENCH_DIR + "/word_list").each do |line|
      training_set << line.chomp
    end
    training_set
  end
  
  def token_test_set(training_set, opts={})
    test_set = []
    training_set_size = training_set.tokens.count
    number_of_tokens = opts[:n] || 10000
    log "generating test set of #{number_of_tokens} tokens"
    number_of_tokens.times do |i|
      if i % 2 == 1
        test_set << training_set.tokens[rand(training_set_size)]
      else
        test_set << "foobarbaz" # assumed not in training set
      end
    end
    log "test set created"
    test_set
  end
  
  def vector_test_set(training_set, opts={})
    test_set = []
    number_of_token_groups = opts[:n] || 10000
    size_of_token_groups = opts[:tokens] || 10
    log "generating test set of #{number_of_token_groups} token groups " + 
    "with #{size_of_token_groups} tokens each"
    silently do
      number_of_token_groups.times do
        test_set << token_test_set(training_set, :n => size_of_token_groups)
      end
    end
    log "test set created"
    test_set
  end
  
end

TSB = TrainingSetBench
#TSB.debugging_on

training_set = TSB.training_set_for_indexing_test
token_test_set = TSB.token_test_set(training_set, :n => N)
vector_test_set = TSB.vector_test_set(training_set, :n => N)
statistical_test_set = vector_test_set.dup

TSB.log "Running TrainingSet Benchmarks for #{N.to_s} inputs"
Benchmark.bm(18) do |bm|
  bm.report("index") do
    N.times do
      token_to_find = token_test_set.pop
      index = training_set.index_of(token_to_find)
      TSB.debug "index of token ``#{token_to_find}'' is ##{index}"
    end
  end
  
  bm.report("vectors") do
    N.times do
      tokens_to_vectorize = vector_test_set.pop
      vector = training_set.vectorize(tokens_to_vectorize)
      # absurd output.
      #TSB.debug("vector representation of #{tokens_to_vectorize.inspect} is #{vector}")
    end
  end
  
  bm.report("anomaly detect init") do
    score = training_set.anomaly_score_of(["foobarbaz"])
    TSB.debug "initialized cached variables for statistical anomaly detector"
  end
  
  bm.report("anomaly detect") do
    N.times do
      tokens_to_analyze = statistical_test_set.pop
      score = training_set.anomaly_score_of(tokens_to_analyze)
      TSB.debug "anomaly score of tokens #{tokens_to_analyze.inspect} is #{score}"
    end
  end
end
