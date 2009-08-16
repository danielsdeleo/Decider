require File.dirname(__FILE__) + '/bench_helper'
require File.dirname(__FILE__) + '/github_contest'

GithubContest::Data.load!
cluster = GithubContest::UsersCluster.new(:vector_type => :tanimoto)


Benchmark.bm(20) do |results|
  results.report("load data:") do
    cluster.load!
  end
  
  results.report("build tree:") do
    cluster.build
  end
  
  results.report("find KNN:") do
    cluster.find_neighbors_of_test_users(100)
  end
  
  cluster.recommendations.each do |recommended_repos|
    puts recommended_repos.emit_recommendations
  end

  
end
