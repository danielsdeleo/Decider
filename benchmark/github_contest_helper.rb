module GithubContest
  
  class DataSet
    attr_reader :users_repos, :users_repos_cluster, :repos_watchers_cluster, :repo_watch_count
    
    def initialize(vector_type=nil)
      @users_repos_cluster = Decider::Clustering::NearestNeighbors.new(vector_type) { |doc| doc.verbatim }
      @repos_watchers_cluster = Decider::Clustering::NearestNeighbors.new(vector_type) { |doc| doc.verbatim }
      @results = nil
      load_data_from_file
      users_to_recommend_to
    end
    
    def load_similar_users_from_file
      @results = []
      IO.foreach(File.dirname(__FILE__) + "/fixtures/github-users-neighbors.txt") do |line|
        user_id, similar_users = line.strip.split(":")
        r = Recommendation.new(user_id.to_i, @users_repos, @repo_watch_count)
        r.similar_users_ids = similar_users.split(",").map { |similar_user| similar_user.to_i }
        @results << r
      end
    end
    
    def load_data_from_file
      @users_repos, @repos_watchers = {}, {}
      @repo_watch_count = Hash.new {0}
      IO.foreach(File.dirname(__FILE__) + "/fixtures/github-contest/data.txt") do |line|
        user, repo = line.strip.split(":").map { |id| id.to_i }
        @repos_watchers[repo] ||= []
        @repos_watchers[repo] << user
        @users_repos[user] ||= []
        @users_repos[user] << repo
        @repo_watch_count[repo] += 1
      end

      stats.total_users = users_repos.size
      @users_repos
    end
    
    def load_users_repos_into_cluster
      @users_repos.each do |user, repos|
        @users_repos_cluster.push(user, repos)
      end
    end
  
    def load_repos_watchers_into_cluster
      @repos_watchers.each do |repo, watchers|
        @repos_watchers_cluster.push(repo, watchers)
      end
    end
    
    def users_to_recommend_to
      @users_to_recommend_to ||= []
      if @users_to_recommend_to.empty?
        IO.foreach(File.dirname(__FILE__) + "/fixtures/github-contest/test.txt") do |line|
          @users_to_recommend_to << line.strip.to_i
        end
      end
      @users_to_recommend_to
    end
    
    # Creates a hash which maps user_id => [similar,user,ids]
    def similar_users_map(k=10)
      unless @results
        @results = each_test_user do |user_id, results|
          r = Recommendation.new(user_id, @users_repos, @repo_watch_count)
          r.similar_users = @users_repos_cluster.knn(k, @users_repos[user_id])
          results << r
        end
      end
      @results
    end
    
    def similar_repos_map(k=5)
      unless @results
        @results = each_test_user do |user_id, results|
          this_users_repos_watchers = {} 
          @users_repos[user_id].each do |repo|
            this_users_repos_watchers[repo] = @repos_watchers[repo]
          end
          r = Recommendation.new(user_id, @users_repos, @repo_watch_count)
          #r.similar_users = @users_repos_cluster.knn(k, @users_repos[user_id])
          results << r
          
          #repos_watchers_cluster.knn(k, )
        end
      end
      @results
    end
    
    def each_test_user(&block)
      results = []
      threads = []
      users_to_recommend_to.partition(4).each do |some_of_the_users|
        threads << Thread.new do
          some_of_the_users.each do |user_id, results|
            yield user_id, results
          end
        end
      end
      threads.each { |t| t.join }
      results
    end
    
    def print_similar_users(fd=$stdout)
      similar_users_map.each do |recommendation|
        fd.puts "#{recommendation.user_id}:" + recommendation.similar_users.join(",")
      end
    end
    
    def recommendations
      recommend = {}
      similar_users_map.each do |similar_user_recommendations|
        user_id = similar_user_recommendations.user_id
        recommend[user_id] = []
        repos_votes = similar_user_recommendations.ranked_repos
        10.times do
          recommend[user_id] << select_best_repo(repos_votes)
        end
      end
      recommend
    end
  
    def stats
      @stats ||= GithubStats.new
    end
    
    def select_best_repo(repos_votes={})
      best_repo = repos_votes.keys.first
      most_votes = repos_votes[best_repo]
      repos_votes.each do |repo, votes|
        best_repo, most_votes = repo, votes if votes > most_votes
      end
      repos_votes.delete(best_repo)
      best_repo
    end
    
  end
  
  class GithubStats
    attr_accessor :total_users
  end
  
  class Recommendation
    attr_reader :user_id, :similar_users
    
    def initialize(user_id, users_repos, repo_watch_count)
      @user_id, @users_repos, @repo_watch_count = user_id, users_repos, repo_watch_count
    end
    
    def similar_users=(similar_users_documents)
      @similar_users = similar_users_documents.map { |doc| doc.name }
    end
    
    def similar_users_ids=(similar_users_ids)
      @similar_users = similar_users_ids
    end
    
    def weight_votes_for_popularity(repos_votes)
      results = {}
      repos_votes.each do |repo, votes|
        results[repo] = votes * @repo_watch_count[repo]
      end
      results
    end
    
    def ranked_repos
      already_watching = @users_repos[@user_id] || []
      watched_by_similar_users = Hash.new {0}
      @similar_users.each do |user|
        @users_repos[user].each do |repo|
          watched_by_similar_users[repo] += 1 unless already_watching.include?(repo)
        end
      end
      #weight_votes_for_popularity(watched_by_similar_users)
      watched_by_similar_users
    end
    
  end
end

