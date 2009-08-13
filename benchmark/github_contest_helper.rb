module GithubContest
  
  CONTEST_DATA_DIR = File.dirname(__FILE__) + "/fixtures/github-mini/"
  
  class DataSet
    attr_reader :users_repos, :users_repos_cluster, :repos_watchers_cluster, :repo_watch_count
    
    def initialize(vector_type=nil)
      p :initialize
      @users_repos_cluster = Decider::Clustering::NearestNeighbors.new(vector_type) { |doc| doc.verbatim }
      @repos_watchers_cluster = Decider::Clustering::NearestNeighbors.new(vector_type) { |doc| doc.verbatim }
      @results = nil
      load_sample_set
      load_test_set
    end
    
    def load_similar_users_from_file
      p :load_similar_users_from_file
      @results = []
      IO.foreach(File.dirname(__FILE__) + "/fixtures/github-users-neighbors.txt") do |line|
        user_id, similar_users = line.strip.split(":")
        r = Recommendation.new(user_id.to_i, @users_repos, @repo_watch_count)
        r.similar_users_ids = similar_users.split(",").map { |similar_user| similar_user.to_i }
        @results << r
      end
    end
    
    def load_sample_set
      p :load_sample_set
      @users_repos, @repos_watchers = {}, {}
      @repo_watch_count = Hash.new {0}
      IO.foreach(CONTEST_DATA_DIR + "data.txt") do |line|
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
      p :load_users_repos_into_cluster
      @users_repos.each do |user, repos|
        @users_repos_cluster.push(user, repos)
      end
    end
    
    def generate_users_repos_tree
      p :generate_users_repos_tree
      @users_repos_cluster.tree
    end
  
    def load_repos_watchers_into_cluster
      p :load_repos_watchers_into_cluster
      @repos_watchers.each do |repo, watchers|
        @repos_watchers_cluster.push(repo, watchers)
      end
    end
    
    def generate_repos_watchers_tree
      p :generate_repos_watchers_tree
      @repos_watchers_cluster.tree
    end
    
    def load_test_set
      p :load_test_set
      @users_to_recommend_to = []
      IO.foreach(CONTEST_DATA_DIR + "test.txt") do |line|
        @users_to_recommend_to << line.strip.to_i
      end
      @users_to_recommend_to
    end
    
    # Creates a hash which maps user_id => [similar,user,ids]
    def find_similar_users(k=10)
      p "find #{k} most similar users"
      unless @results
        @results = each_test_user do |user_id, results|
          r = Recommendation.new(user_id, @users_repos)
          r.similar_users = @users_repos_cluster.knn(k, @users_repos[user_id])
          results << r
        end
      end
      @results
    end
    
    def find_similar_repos(k=5)
      p "find #{k} most similar repos"
      unless @results
        @results = each_test_user do |user_id, results|
          this_users_repos_watchers = {} 
          p "(#{user_id}) collecting this user's repo-watchers pairs"
          @users_repos[user_id].each do |repo|
            this_users_repos_watchers[repo] = @repos_watchers[repo]
          end
          p :finding_recommendations
          r = Recommendation.new(user_id, @users_repos)
          this_users_repos_watchers.each do |repo, watchers|
            k_nearest_repos = @repos_watchers_cluster.knn(k, watchers).map { |repo_doc| repo_doc.name}
            r.recommend_repos(k_nearest_repos)
          end
          results << r
          
        end
      end
      @results
    end
    
    def each_test_user(&block)
      p :each_test_user
      results = []
      threads = []
      load_test_set.partition(4).each do |some_of_the_users|
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
      @results.each do |result|
        user_id = result.user_id
        recommend[user_id] = result.best_recommendations
      end
      recommend
    end
  
    def stats
      @stats ||= GithubStats.new
    end
    
  end
  
  class GithubStats
    attr_accessor :total_users
  end
  
  class Recommendation
    attr_reader :user_id, :similar_users
    
    def initialize(user_id, users_repos)
      @user_id, @users_repos = user_id, users_repos
    end
    
    def similar_users=(similar_users_documents)
      @similar_users = similar_users_documents.map { |doc| doc.name }
    end
    
    def similar_users_ids=(similar_users_ids)
      @similar_users = similar_users_ids
    end
    
    def already_watching?(repo_id)
      @already_watching_repos ||= @users_repos[@user_id] || []
      @already_watching_repos.include?(repo_id)
    end
    
    def recommend(repo_id)
      @recommended_repos ||= Hash.new {0}
      @recommended_repos[repo_id] += 1 unless already_watching?(repo)
    end
    
    def recommend_repos(repos=[])
      repos.each { |repo| recommend(repo) }
    end
    
    def recommend_repos_by_user_similarity
      @similar_users.each do |user|
        @users_repos[user].each { |repo| recommend repo }
      end
      best_recommendations
    end
    
    def best_recommendations
      recommended_repos = @recommended_repos.dup
      recommend[user_id] = []
      10.times do
        recommend[user_id] << select_most_recommended_repo(recommended_repos)
      end
      recommend
    end
    
    def select_most_recommended_repo(repos_votes={})
      best_repo = repos_votes.keys.first
      most_votes = repos_votes[best_repo]
      repos_votes.each do |repo, votes|
        best_repo, most_votes = repo, votes if votes > most_votes
      end
      repos_votes.delete(best_repo)
      best_repo
    end
    
  end
end

