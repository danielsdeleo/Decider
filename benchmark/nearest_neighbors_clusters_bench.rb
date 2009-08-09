require File.dirname(__FILE__) + '/bench_helper'
require "pp"

module NearestNeighborsClustersBench
  
  class DataSet
    attr_reader :users_repos, :cluster
    
    def initialize
      @cluster = Decider::Clustering::NearestNeighbors.new { |doc| doc.verbatim }
      
      load_data_from_file
      users_to_recommend_to
    end
    
    def load_data_from_file
      @users_repos = {}
      IO.foreach(File.dirname(__FILE__) + "/fixtures/github-contest/data.txt") do |line|
        user, repo = line.strip.split(":").map { |id| id.to_i }
      
        #p [user, repo]
        @users_repos[user] ||= []
        @users_repos[user] << repo
      end

      stats.total_users = users_repos.size
      @users_repos
    end
    
    def load_github_data_into_cluster
      # Users #5 and #9 are jerks
      @users_repos.each do |user, repos|
        @cluster.push(user, repos) unless repos.size < 5
      end
    end
  
    def users_to_recommend_to
      @users_to_recommend_to ||= []
      if @users_to_recommend_to.empty?
        IO.foreach(File.dirname(__FILE__) + "/fixtures/github-contest/test.txt") do |line|
          @users_to_recommend_to << line.strip.to_i
        end
      end
      @users_to_recommend_to
    end
    
    def similar_users_map(k=10)
      # This could be threaded for max awesomness in Jruby
      @similar_users_map ||= users_to_recommend_to.map do |user_id|
        r = Recommendation.new(user_id, @users_repos)
        puts user_id.to_s
        r.similar_users =  cluster.knn(k, users_repos[user_id])
        # puts "for user #{user_id}, found these similar users:"
        # puts r.similar_users.map { |user| user.doc.name.to_s }.join(",")
        # puts
        r
      end
    end
    
    def recommendations
      similar_users_map.each do |similar_user_recommendations|
        p similar_user_recommendations.ranked_repos
      end
    end
  
    def stats
      @stats ||= GithubStats.new
    end
  end
  
  class GithubStats
    attr_accessor :total_users
  end
  
  class Recommendation
    attr_reader :user_id
    
    def initialize(user_id, users_repos)
      @user_id, @users_repos = user_id, users_repos
    end
    
    def similar_users=(similar_users_vectors)
      @similar_users = similar_users_vectors.map { |user| user.doc.name }
    end
    
    def ranked_repos
      already_watching = users_repos[@user_id]
      watched_by_similar_users = Hash.new {0}
      @similar_users.each do |user|
        @users_repos[user].each do |repo|
          watched_by_similar_users[repo] += 1 unless already_watching.include?(repo)
        end
      end
      watched_by_similar_users
    end
    
  end
end

github_data = NearestNeighborsClustersBench::DataSet.new

Benchmark.bm(20) do |results|
  results.report("load data:") do
    github_data.load_github_data_into_cluster
  end
  
  results.report("build tree:") do
    github_data.cluster.tree
  end
  
  results.report("find KNN:") do
    github_data.similar_users_map
  end
  
  results.report("vote on repos:") do
    github_data.recommendations
  end 
  
end