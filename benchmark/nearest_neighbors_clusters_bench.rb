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

    p users_repos.size

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
end

cluster = Decider::Clustering::NearestNeighbors.new { |doc| doc.verbatim }
NNCB = NearestNeighborsClustersBench

Benchmark.bm(20) do |results|
  results.report("load data:") do
    NNCB.load_github_data(cluster)
  end
  
  results.report("build tree:") do
    cluster.tree
  end
  
  results.report(":find KNNs") do
    NNCB.users_to_recommend_to.each do |userid|
      vector = NNCB.users_repos[userid]
      p cluster.knn(10, vector)
    end
  end
end