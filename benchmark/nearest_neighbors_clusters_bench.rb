require File.dirname(__FILE__) + '/bench_helper'

module NearestNeighborsClustersBench
  extend self
  
  attr_reader :users_repos
  
  def load_github_data(clusterer)
    @users_repos = {}
    IO.foreach(File.dirname(__FILE__) + "/fixtures/github-contest/data.txt") do |line|
      user, repo = line.strip.split(":").map { |id| id.to_i }
      
      #p [user, repo]
      @users_repos[user] ||= []
      @users_repos[user] << repo
    end

    stats.total_users = users_repos.size

    @users_repos.each do |user, repos|
      clusterer.push(user, repos)
    end
  end
  
  def users_to_recommend_to
    users = []
    IO.foreach(File.dirname(__FILE__) + "/fixtures/github-contest/test.txt") do |line|
      users << line.strip.to_i
    end
    users
  end
  
  def stats
    @stats ||= GithubStats.new
  end
  
  class GithubStats
    attr_accessor :total_users
  end
  
  class Recommendation
    def initialize(user_id)
      @user_id = user_id
    end
    
    def similar_users=(similar_users_vectors)
      @similar_users = similar_users_vectors.map { |user| user.doc.name }
    end
    
    def ranked_repos(users_repos)
      already_watching = users_repos[@user_id]
      watched_by_similar_users = Hash.new {0}
      @similar_users.each do |user|
        users_repos[user].each do |repo|
          watched_by_similar_users[repo] += 1 unless already_watching.include?(repo)
        end
      end
      watched_by_similar_users
    end
    
  end
end

cluster = Decider::Clustering::NearestNeighbors.new { |doc| doc.verbatim }
NNCB = NearestNeighborsClustersBench
recommendations = []

Benchmark.bm(20) do |results|
  results.report("load data:") do
    NNCB.load_github_data(cluster)
  end
  
  results.report("build tree:") do
    cluster.tree
  end
  
  results.report("find KNNs:") do
    # users_to_recommend_to = NNCB.users_to_recommend_to
    # Use threads here: 
    # users1 = users_to_recommend_to.slice!(Range.new(0, users_to_recommend_to.size / 2 - 1))
    # users2 = users_to_recommend_to
    recommendations = NNCB.users_to_recommend_to.map do |userid|
      vector = NNCB.users_repos[userid]
      knn =  cluster.knn(10, vector)
      puts "for user #{userid}, found these similar users:"
      puts knn.map { |neighbor| neighbor.doc.name.to_s }.join(",")
      puts
      r = NNCB::Recommendation.new(userid)
      r.similar_users = knn
      r
    end
  end
  
  results.report("vote on repos:") do
    recommendations.each do |recommendation|
      p recommendation.ranked_repos(NNCB.users_repos)
    end
  end 
  
end