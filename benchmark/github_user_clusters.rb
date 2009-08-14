require File.dirname(__FILE__) + '/bench_helper'
require File.dirname(__FILE__) + '/github_contest_helper'

github_data = GithubContest::DataSet.new #(:tanimoto)

Benchmark.bm(20) do |results|
  results.report("load data:") do
    github_data.load_users_repos_into_cluster
  end
  
  results.report("build tree:") do
    github_data.generate_users_repos_tree
  end
  
  results.report("find KNN:") do
    github_data.find_similar_users(60)
  end

  begin
    fd = File.open(File.dirname(__FILE__) + "/fixtures/github-users-neighbors.txt", "w+")
    github_data.print_similar_users(fd)
  ensure
    fd.close
  end

  
end
