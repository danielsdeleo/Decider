require File.dirname(__FILE__) + '/bench_helper'
require File.dirname(__FILE__) + '/github_contest_helper'

require "pp"

github_data = GithubContest::DataSet.new(:tanimoto)
github_data.load_similar_users_from_file

github_data.recommendations.each do |user_id, repo_ids|
  puts user_id.to_s + ":" + repo_ids.join(",")
end
