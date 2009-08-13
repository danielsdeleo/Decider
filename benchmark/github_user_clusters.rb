require File.dirname(__FILE__) + '/bench_helper'
require File.dirname(__FILE__) + '/github_contest_helper'

github_data = NearestNeighborsClustersBench::DataSet.new

Benchmark.bm(20) do |results|
  results.report("load data:") do
    github_data.load_github_data_into_cluster
  end
  
  results.report("build tree:") do
    github_data.cluster.tree
  end
  
  results.report("find KNN:") do
    github_data.similar_users_map(5)
  end

  begin
    fd = File.open(File.dirname(__FILE__) + "/fixtures/github-users-neighbors.txt", "w+")
    github_data.print_similar_users(fd)
  ensure
    fd.close
  end

  
end