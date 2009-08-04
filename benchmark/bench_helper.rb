# encoding: UTF-8
require "benchmark"
require "logger"
require "rubygems"
require File.dirname(__FILE__) + '/../lib/decider'

BENCH_DIR = File.dirname(__FILE__)

unless "".respond_to?(:force_encoding)
  class String
    def force_encoding(*args)
      self
    end
  end
end

module BenchHelper
  module Logging
    
    class SimpleLogFormat < Logger::Formatter
      def call(severity, time, program_name, message)
        "[#{severity}] #{message} \n"
      end
    end

    def logger
      unless @logger 
        @logger = Logger.new(STDERR)
        @logger.formatter = SimpleLogFormat.new
        @logger.level = Logger::INFO
      end
      @logger
    end

    def log(msg)
      logger.info(msg)
    end

    def debug(msg)
      logger.debug(msg)
    end
    
    def debugging_on
      logger.level = Logger::DEBUG
    end
    
    def silently
      current_log_level = @logger.level
      @logger.level = Logger::FATAL
      yield
      @logger.level = current_log_level
    end

  end
  
  module SaCorpusData
    
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

    def load_corpus_data
      fail_unless_sa_corpus_available
      dirs = {:training_ham => "easy_ham", :training_spam => "spam", :test_ham => "easy_ham_2", :test_spam => "spam_2"}
      data = {}
      dirs.each do |key, dir|
        data[key] = []
        Dir.glob(BENCH_DIR + "/fixtures/#{dir}/*").each do |email|
          data[key] << IO.read(email).force_encoding("ISO-8859-1")
        end
      end
      data
    end
  end
end