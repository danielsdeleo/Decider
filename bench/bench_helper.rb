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
end