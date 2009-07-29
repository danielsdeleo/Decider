#!/usr/bin/env ruby
# encoding: UTF-8
require File.dirname(__FILE__) + '/bench_helper'

module BayesBench
  
  class AccuracyStats
    attr_accessor :training_ham, :training_spam, :test_ham, :test_spam, :false_positives, :false_negatives
    
    def report
      msg = ""
      msg << "## Training Messages ##\n"
      msg << "#{training_ham + training_spam} messages total, #{training_spam} spam, #{training_ham} ham\n"
      msg << "\n"
      msg << "## Testing Messages ##\n"
      total_test_msgs = test_ham + test_spam
      msg << "#{total_test_msgs} total, #{test_spam} spam, #{test_ham} ham\n"
      false_neg_percent = (false_negatives.to_f / test_spam.to_f) * 100.0
      msg << "#{false_negatives} (#{false_neg_percent}%) messages wrongly marked ham (false negatives)\n"
      false_pos_percent = (false_positives.to_f / test_ham.to_f) * 100.0
      msg << "#{false_positives} (#{false_pos_percent}%) messages wrongly marked spam (false positives)\n"
      total_errors = false_positives + false_negatives
      accurracy = 100.0 - ((total_errors.to_f * 100.0)/ total_test_msgs.to_f)
      msg << "Accuracy: #{accurracy}%\n"
      msg << "#{total_errors} errors out of #{total_test_msgs} messages\n"
      puts msg
    end
    
  end
  
  include BenchHelper::Logging
  
  extend self
  
  def fail_unless_sa_corpus_available
    dirs = %w{easy_ham easy_ham_2 spam spam_2}.map { |subdir| BENCH_DIR + "/fixtures/" }
    dirs.each do |dir|
      unless File.exist?(dir)
        fail_msg = "You need the Spam Assasin corpus to run the benchmark.\n\n" +
        IO.read(BENCH_DIR + "/fixtures/README") 
        fail(fail_msg)
      end
    end
  end
  
  def preload_data
    #dirs = {:training_ham => "easy_ham", :training_spam => "spam", :test_ham => "easy_ham_2", :test_spam => "spam_2"}
    dirs = {:training_ham => "easy_ham", :training_spam => "spam", :test_ham => "easy_ham_2", :test_spam => "spam_2"}
    @data = {}
    dirs.each do |key, dir|
      @data[key] = []
      Dir.glob(BENCH_DIR + "/fixtures/#{dir}/*").each do |email|
        @data[key] << IO.read(email).force_encoding("ISO-8859-1")
      end
    end
    @accuracy_stats = AccuracyStats.new
    @accuracy_stats.training_ham = @data[:training_ham].length
    @accuracy_stats.training_spam = @data[:training_spam].length
    @accuracy_stats.test_ham = @data[:test_ham].length
    @accuracy_stats.test_spam = @data[:test_spam].length
  end
  
  def train_on_spam(classifier)
    @data[:training_spam].each do |msg|
      classifier.spam << msg
    end
  end
  
  def train_on_ham(classifier)
    @data[:training_ham].each do |msg|
      classifier.ham << msg
    end
  end
  
  def test_spam(classifier)
    false_negatives = 0
    @data[:test_spam].each do |msg|
      false_negatives += 1 unless classifier.spam?(msg)
    end
    @accuracy_stats.false_negatives = false_negatives
  end
  
  def test_ham(classifier)
    false_positives = 0
    @data[:test_ham].each do |msg|
      false_positives += 1 unless classifier.ham?(msg)
    end
    @accuracy_stats.false_positives = false_positives
  end
  
  def print_report
    @accuracy_stats.report
  end
  
end

BB = BayesBench
BB.fail_unless_sa_corpus_available
BB.preload_data

classifier = Decider.classifier(:spam, :ham) do |doc|
  doc.plain_text
  #doc.ngrams(2)
  #doc.stem
end

Benchmark.bm(18) do |bm|
  
  GC.start
  
  bm.report("Train Classifier") do
    BB.train_on_ham(classifier)
    BB.train_on_spam(classifier)
  end
    
  GC.start
  
  bm.report("Classify") do
    BB.test_spam(classifier)
    BB.test_ham(classifier)
  end
end

BB.print_report

