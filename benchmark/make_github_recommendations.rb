require File.dirname(__FILE__) + '/bench_helper'
require File.dirname(__FILE__) + '/github_contest_helper'

require "pp"

github_data = NNCB::DataSet.new
github_data.load_similar_users_from_file

num_recommended_repos = github_data.recommendations.map do |recommendation|
  recommendation.size #.size if recommendation.size < 10
end
p Math.avg num_recommended_repos