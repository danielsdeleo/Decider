#!/usr/bin/env ruby
# encoding: UTF-8
require File.dirname(__FILE__) + '/bench_helper'

module HierarchicalClusterBench
  include BenchHelper::Logging
  include BenchHelper::SaCorpusData
  
  def subject_line(email)
    r = /Subject\: (.*)/
    md = r.match(email)
    md ? md[1][0..14] : "Undeciperable"
  end
  
  extend self
  
  def load_data(clusterer)
    @data = load_corpus_data
    # @data[:training_spam].each do |email|
    #   clusterer.push("spam: " + subject_line(email), email)
    # end
    # @data[:training_ham].each do |email|
    #   clusterer.push("spam: " + subject_line(email), email)
    # end
    @data[:test_ham].each do |email|
      clusterer.push("ham: " + subject_line(email), email)
    end
    @data[:test_spam].each do |email|
      clusterer.push("spam: " + subject_line(email), email)
    end
    
  end
  
end

clusterer = Decider::Clustering::Base.new do |doc|
  doc.plain_text
  doc.final
end

HSB = HierarchicalClusterBench

Benchmark.bm(18) do |bm|
  
  bm.report("loading") do
    HSB.load_data(clusterer)
  end
  
  bm.report("create token index hsh") do
    clusterer.send(:token_indices)
  end
  
  #p "token count: #{clusterer.send(:token_indices).length}"
  
  bm.report("calculate vectors") do
    clusterer.vectors
  end
  
  bm.report("create tree") do
    clusterer.tree
  end
  
  bm.report("print tree") do
    puts clusterer.tree.to_formatted_s
  end
  
end

