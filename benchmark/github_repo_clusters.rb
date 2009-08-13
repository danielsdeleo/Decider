require File.dirname(__FILE__) + '/bench_helper'
require File.dirname(__FILE__) + '/github_contest_helper'

github_data = GithubContest::DataSet.new()

Benchmark.bm(20) do |results|
  results.report("load data:") do
    github_data.load_repos_watchers_into_cluster
  end
  
  results.report("build tree:") do
    github_data.repos_watchers_cluster.tree
  end
  
  results.report("find KNN:") do
    github_data.find_similar_repos(10)
  end

  github_data.recommendations.each do |user_id, recommended_repo_ids|
    puts user_id.to_s + ":" + recommended_repo_ids.join(",")
  end
  
end