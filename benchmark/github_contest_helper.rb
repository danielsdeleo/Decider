module GithubContest
  
  CONTEST_DATA_DIR = File.dirname(__FILE__) + "/fixtures/github/"
  
  class DataSet
    attr_reader :users_repos, :users_repos_cluster, :repos_watchers_cluster, :repo_watch_count
    
    def initialize(vector_type=nil)
      p :initialize
      @users_repos_cluster = Decider::Clustering::NearestNeighbors.new(vector_type) { |doc| doc.verbatim }
      @repos_watchers_cluster = Decider::Clustering::NearestNeighbors.new(vector_type) { |doc| doc.verbatim }
      @repos_similar_repos = {}
      @results = nil
      load_sample_set
      load_test_set
    end
    
    def load_similar_users_from_file
      p :load_similar_users_from_file
      @results = []
      IO.foreach(File.dirname(__FILE__) + "/fixtures/github-users-neighbors.txt") do |line|
        user_id, similar_users = line.strip.split(":")
        r = Recommendation.new(user_id.to_i, @users_repos)
        r.similar_users_ids = similar_users.split(",").map { |similar_user| similar_user.to_i }
        r.recommend_repos_by_user_similarity
        @results << r
      end
    end
    
    def load_sample_set
      p :load_sample_set
      @users_repos, @repos_watchers = Hash.new {|hsh,key| hsh[key]=[]}, Hash.new {|hsh,key| hsh[key]=[]}
      @repo_popularity = Hash.new(0)
      IO.foreach(CONTEST_DATA_DIR + "data.txt") do |line|
        user, repo = line.strip.split(":").map { |id| id.to_i }
        @repo_popularity[repo] += 1
        @repos_watchers[repo] << user
        @users_repos[user] << repo
      end
      Recommendation.repo_popularity = @repo_popularity
      
      stats.total_users = users_repos.size
      @users_repos
    end
    
    def load_users_repos_into_cluster
      p :load_users_repos_into_cluster
      @users_repos.each do |user, repos|
        # everyone who only watches rails is a fail.
        @users_repos_cluster.push(user, repos) unless repos.size > 5
      end
    end
    
    def generate_users_repos_tree
      p :generate_users_repos_tree
      @users_repos_cluster.tree
    end
  
    def load_repos_watchers_into_cluster
      p :load_repos_watchers_into_cluster
      @repos_watchers.each do |repo, watchers|
        @repos_watchers_cluster.push(repo, watchers) unless watchers.size > 5
      end
    end
    
    def generate_repos_watchers_tree
      p :generate_repos_watchers_tree
      @repos_watchers_cluster.tree
      begin
        fd = File.open(File.dirname(__FILE__) + "/fixtures/repos-watchers-cluster.rbm", "w+")
        fd.puts Marshal.dump(@repos_watchers_cluster.tree)
      ensure
        fd.close
      end
    end
    
    def load_test_set
      @users_to_recommend_to ||= begin
        p :load_test_set
        user_ids = []
        IO.foreach(CONTEST_DATA_DIR + "test.txt") do |line|
          user_ids << line.strip.to_i
        end
        user_ids
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
          @users_repos[user_id].each do |repo|
            this_users_repos_watchers[repo] = @repos_watchers[repo]
          end
          r = Recommendation.new(user_id, @users_repos)
          this_users_repos_watchers.each do |repo, watchers|
            @repos_similar_repos[repo] ||= @repos_watchers_cluster.knn(k, watchers).map { |repo_doc| repo_doc.name}
            r.recommend_repos(@repos_similar_repos[repo])
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
      load_test_set.partition(16).each do |some_of_the_users|
        threads << Thread.new do
          some_of_the_users.each do |user_id|
            block.call(user_id, results)
          end
        end
      end
      threads.each { |t| t.join }
      results
    end
    
    def print_similar_users(fd=$stdout)
      @results.each do |recommendation|
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
    attr_accessor :recommended_repos
    attr_reader :user_id, :similar_users
    
    class << self
      def repo_popularity=(repo_popularity)
        default_recommendation = Recommendation.new(-1, {})
        default_recommendation.recommended_repos = repo_popularity
        @most_popular_repos = default_recommendation.best_recommendations
      end
      
      def most_popular_repos
        @most_popular_repos.dup
      end
    end
    
    def initialize(user_id, users_repos)
      @user_id, @users_repos = user_id, users_repos
      @most_popular_repos = self.class.most_popular_repos
    end
    
    def similar_users=(similar_users_documents)
      @similar_users = similar_users_documents.map { |doc| doc.name }
    end
    
    def similar_users_ids=(similar_users_ids)
      @similar_users = similar_users_ids
    end
    
    def already_watching?(repo_id)
      @already_watching_repos ||= (@users_repos[@user_id] || [])
      @already_watching_repos.include?(repo_id)
    end
    
    def recommend(repo_id)
      @recommended_repos ||= Hash.new {0}
      @recommended_repos[repo_id] += 1 unless already_watching?(repo_id)
    end
    
    def recommend_repos(repos)
      #puts "recommending " + repos.inspect
      repos.each do |repo_id| 
        recommend(repo_id)
      end
    end
    
    def recommend_repos_by_user_similarity
      @similar_users.each do |user|
        @users_repos[user].each { |repo| recommend repo }
      end
      best_recommendations
    end
    
    def best_recommendations
      recommended_repos = @recommended_repos.dup
      best_repos = []
      10.times do
        best_repos << (select_most_recommended_repo(recommended_repos)|| @most_popular_repos.shift)
      end
      best_repos
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

