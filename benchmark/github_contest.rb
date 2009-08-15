require "singleton"

class GithubContest
  CONTEST_DATA_DIR = File.dirname(__FILE__) + "/fixtures/github/"
  
  class Data
    include Singleton
    
    class << self
      
      def load!
        unless data_loaded?
          instance.load_sample_data
          instance.load_test_data
          instance.loaded
        end
      end
      
      def data_loaded?
        instance.data_loaded?
      end
      
      def repos_watched_by(user)
        instance.users_repos[user]
      end
      
      def users_watching(repo)
        instance.repos_watchers[repo]
      end
      
      def each_user(&block)
        instance.users_repos.each(&block)
      end
      
      def each_repo(&block)
        instance.repos_watchers.each(&block)
      end
      
      def test_users
        instance.test_users
      end
      
      def all_repos
        instance.repos_watchers.keys
      end
      
      def ten_most_popular_remaining_for(user)
        unless @popular_repos
          @popular_repos = RecommendedRepos.new(-1)
          @popular_repos.may_include(instance.repo_popularity)
        end
        @popular_repos.ten_best_repos_for(user)
      end
      
    end
    
    attr_reader :users_repos, :repos_watchers, :repo_popularity, :test_users
    
    def initialize
      @users_repos, @repos_watchers = Hash.new {|hsh,key| hsh[key]=[]}, Hash.new {|hsh,key| hsh[key]=[]}
      @repo_popularity = Hash.new(0)
      @test_users = []
      @loaded = false
    end
    
    def load_sample_data
      unless data_loaded?
        IO.foreach(CONTEST_DATA_DIR + "data.txt") do |line|
          user, repo = line.strip.split(":").map { |id| id.to_i }
          @repo_popularity[repo] += 1
          @repos_watchers[repo] << user
          @users_repos[user] << repo
        end
      end
    end
    
    def load_test_data
      unless data_loaded?
        IO.foreach(CONTEST_DATA_DIR + "test.txt") do |line|
          @test_users << line.strip.to_i
        end
      end
    end
    
    def loaded
      @loaded = true
    end
    
    def data_loaded?
      @loaded
    end
    
  end
  
  class SimilarUsers
    
    class << self
      def load_string(string)
        raise ArgumentError, "invalid SimilarUsers string: ``#{string}''" if invalid_string?(string)
        test_user, users_and_metrics = string.chomp.split(":")
        similar_user = new(test_user.to_i)
        users_and_metrics.split(";").each do |user_and_metric|
          user, metric = user_and_metric.split("=>")
          metric = (metric =~ /[\d]+\.[\d]+/ ? metric.to_f : metric.to_i)
          similar_user.user(:id => user.to_i, :metric => metric)
        end
        similar_user
      end
      
      def invalid_string?(string)
        @validation_regex ||= /^[\d]+\:([\d]+\=\>[\d]+(\.[\d]+)?;)+$/
        @validation_regex.match(string).nil?
      end
      
    end
    
    attr_reader :users_with_metrics, :test_user
    
    def initialize(test_user)
      @test_user = test_user
      @users_with_metrics = {}
    end
    
    def user(attrs)
      @users_with_metrics[attrs[:id]] = attrs[:metric]
    end
    
    def users(users_with_metrics_hash={})
      @users_with_metrics = users_with_metrics_hash
    end
    
    def to_recommended_repos
      recommended_repos = RecommendedRepos.new(@test_user)
      @users_with_metrics.each do |user, metric|
        Data.repos_watched_by(user).each do |repo|
          recommended_repos.consider_repo(:id=>repo,:metric=>metric)
        end
      end
      recommended_repos
    end
    
    def to_s
      string = @test_user.to_s + ":"
      @users_with_metrics.each { |user, metric| string << "#{user}=>#{metric};" }
      string
    end
    
  end
  
  class RecommendedRepos
    
    def initialize(test_user_or_repo_id)
      @test_subject_id = test_user_or_repo_id
      @repos_with_metrics = Hash.new { |hsh, key| hsh[key] = [] }
    end
    
    def test_user
      @test_subject_id
    end
    alias :test_repo :test_user
    
    def consider_repo(attrs)
      @repos_with_metrics[attrs[:id]] << attrs[:metric]
    end
    
    def may_include(repos_with_metrics_hash={})
      repos_with_metrics_hash.each do |repo, metric|
        consider_repo(:id => repo, :metric => metric)
      end
    end
    
    def repos_with_metrics(opts={})
      if user = opts[:exclude_users_repos]
        exclusive_repos_with_metrics = {}
        @repos_with_metrics.each do |repo, metric| 
          exclusive_repos_with_metrics[repo] = metric unless Data.repos_watched_by(user).include?(repo)
        end
        exclusive_repos_with_metrics
      else
        @repos_with_metrics
      end
    end
    
    def ranked_repos(opts={})
      with_rankings = {}
      repos_with_metrics(opts).each do |repo_id, metrics|
        with_rankings[repo_id] = metrics.inject(0.0) { |sum, metric| sum + (1.0 /(1.0 + metric))  }
      end
      with_rankings
    end
    
    def emit_recommendations_for(user=nil)
      user ||= @test_subject_id
      user.to_s + ":" + recommendations_for(user).join(",")
    end
    alias :emit_recommendations :emit_recommendations_for
    
    def recommendations_for(user)
      recommendations = ten_best_repos_for(user).compact
      unless recommendations.size == 10
        popular_repos = Data.ten_most_popular_remaining_for(user)
        (10 - recommendations.size).times do
          recommendations << popular_repos.pop
        end
      end
      recommendations
    end
    
    def ten_best_repos_for(user)
      exclusive_ranked_repos = ranked_repos(:exclude_users_repos=>user)
      ten_best = []
      10.times do
        ten_best << select_best_from(exclusive_ranked_repos)
      end
      ten_best
    end
    
    def select_best_from(exclusive_ranked_repos)
      best_repo = exclusive_ranked_repos.keys.first
      best_ranking = exclusive_ranked_repos[best_repo]
      exclusive_ranked_repos.each do |repo, ranking|
        best_repo, best_ranking = repo, ranking if ranking > best_ranking
      end
      exclusive_ranked_repos.delete(best_repo)
      best_repo
    end
    
  end
  
  class GenericCluster
    attr_reader :cluster
    
    def initialize(opts={})
      vt = opts[:vector_type]
      @cluster = Decider::Clustering::NearestNeighbors.new(vt) { |repos_vector| repos_vector.verbatim }
      @minimum_watches = opts[:require_watches] || 0
    end
    
    def load!
      Data.load!
    end
    
    def build
      @cluster.tree
    end
    
  end
  
  class UsersCluster < GenericCluster
    attr_reader :all_similar_users
    
    def initialize(*args)
      super
      @all_similar_users = []
    end
    
    def load!
      super
      Data.each_user do |user, watched_repos|
        @cluster.push(user, watched_repos) if (watched_repos.size >= @minimum_watches)
      end
    end
    
    def find_neighbors_of_test_users(k=10)
      mutex = Mutex.new
      threads = []
      Data.test_users.partition(16).each do |users_subset|
        threads << Thread.new do
          users_subset.each do |test_user|
            similar_users = users_similar_to(test_user, :k=>k)
            mutex.synchronize { @all_similar_users << similar_users }
          end
        end
      end
      threads.each { |t| t.join }
    end
    
    def users_similar_to(user, opts={})
      k = opts[:k] || 10
      similar_users = SimilarUsers.new(user)
      @cluster.knn(k, Data.repos_watched_by(user), :include_scores=>true).each do |user_doc, metric|
        similar_users.user(:id => user_doc.name, :metric => metric)
      end
      similar_users
    end
    
    def recommendations
      @all_similar_users.map { |similar_users| similar_users.to_recommended_repos }
    end
    
  end
  
  class ReposCluster < GenericCluster
    attr_reader :all_similar_repos
    
    def initialize(*args)
      super
      @all_similar_repos = []
    end

    def load!
      super
      Data.each_repo do |repo, watchers|
        @cluster.push(repo, watchers) if (watchers.size >= @minimum_watches)
      end
    end
    
    def repos_similar_to(repo, opts={})
      k = opts[:k] || 10
      similar_repos = RecommendedRepos.new(repo)
      @cluster.knn(k, Data.users_watching(repo), :include_scores=>true).each do |repo_doc, metric|
        similar_repos.consider_repo(:id => repo_doc.name, :metric => metric)
      end
      similar_repos
    end
    
    def find_neighbors_of_all_repos(k=10)
      mutex = Mutex.new
      threads = []
      Data.all_repos.partition(16).each do |repos_subset|
        threads << Thread.new do
          repos_subset.each do |repo_id|
            similar_repos = repos_similar_to(repo, :k=>k)
            mutex.synchronize {@all_similar_repos << similar_repos}
          end
        end
      end
      threads.each { |t| t.join }
    end
  
  end
  
end