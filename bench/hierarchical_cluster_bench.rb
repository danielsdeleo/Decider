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
    @data[:training_spam].each do |email|
      clusterer.push("spam: " + subject_line(email), email)
    end
    @data[:test_ham].each do |email|
      clusterer.push("ham: " + subject_line(email), email)
    end
    # @data[:test_spam].each do |email|
    #   clusterer.push("spam: " + subject_line(email), email)
    # end
    
  end
  
end

clusterer = Decider::Clustering::Base.new do |doc|
  doc.plain_text
end

HSB = HierarchicalClusterBench

Benchmark.bm(18) do |bm|
  
  bm.report("loading") do
    HSB.load_data(clusterer)
  end
  
  # TODO: time the document -> vector process
  # gc_prevention = []
  # bm.report("calc vector space") do
  #   clusterer.corpus.documents.each {|d| gc_prevention << binary_vector(d)}
  # end
  
  bm.report("create tree") do
    puts clusterer.tree.to_formatted_s
  end
  
end

