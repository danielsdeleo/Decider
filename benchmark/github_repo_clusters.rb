require File.dirname(__FILE__) + '/bench_helper'
require File.dirname(__FILE__) + '/github_contest'

GithubContest::Data.load!
cluster = GithubContest::ReposCluster.new(:require_watches => 2, :vector_type => :tanimoto)

Benchmark.bm(20) do |results|
  results.report("load data:") do
    cluster.load!
  end
  
  results.report("build tree:") do
    cluster.build
  end
  
  results.report("find KNN:") do
    cluster.find_neighbors_of_all_repos(10)
  end
  
  begin
    fd = File.open(BENCH_DIR + "/repos_neighbors.txt", "w+")
    cluster.all_similar_repos.each do |similar_repos|
      fd.puts similar_repos.to_s
    end
  ensure
    fd.close
  end
    
end