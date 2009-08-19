require File.dirname(__FILE__) + '/bench_helper'
require File.dirname(__FILE__) + '/github_contest'


GithubContest::Data.load!

repos_similar_to = {}
IO.foreach(BENCH_DIR + "/repos_neighbors.txt") do |line|
  r = GithubContest::RecommendedRepos.load_string(line.strip)
  repos_similar_to[r.test_repo] = r
end

GithubContest::Data.test_users.each do |test_user|
  recommended_repos = GithubContest::RecommendedRepos.new(test_user)
  GithubContest::Data.repos_watched_by(test_user).each do |watched_repo|
    repos_similar_to[watched_repo].repos_with_metrics.each do |similar_repo, metrics|
      unless GithubContest::Data.repos_watched_by(test_user).include?(similar_repo)
        recommended_repos.consider_repo(:id=>similar_repo, :metric=>metrics.first)
      end
    end
  end
  puts recommended_repos.emit_recommendations
end