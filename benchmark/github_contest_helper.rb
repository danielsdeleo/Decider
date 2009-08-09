module NearestNeighborsClustersBench
  
  class DataSet
    attr_reader :users_repos, :cluster
    
    def initialize
      @cluster = Decider::Clustering::NearestNeighbors.new { |doc| doc.verbatim }
      @similar_users_map = nil
      load_data_from_file
      users_to_recommend_to
    end
    
    def load_similar_users_from_file
      @similar_users_map = []
      IO.foreach(File.dirname(__FILE__) + "/fixtures/github-users-neighbors.txt") do |line|
        user_id, similar_users = line.strip.split(":")
        r = Recommendation.new(user_id.to_i, @users_repos)
        r.similar_users_ids = similar_users.split(",").map { |similar_user| similar_user.to_i }
        @similar_users_map << r
      end
    end
    
    def load_data_from_file
      @users_repos = {}
      IO.foreach(File.dirname(__FILE__) + "/fixtures/github-contest/data.txt") do |line|
        user, repo = line.strip.split(":").map { |id| id.to_i }
      
        @users_repos[user] ||= []
        @users_repos[user] << repo
      end

      stats.total_users = users_repos.size
      @users_repos
    end
    
    def load_github_data_into_cluster
      @users_repos.each do |user, repos|
        @cluster.push(user, repos) unless repos.size < 3
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
      unless @similar_users_map
        @similar_users_map = [] 
        threads = []
        users_to_recommend_to.partition(4).each do |some_of_the_users|
          threads << Thread.new do
            some_of_the_users.each do |user_id|
              #p "User: #{user_id}"
              r = Recommendation.new(user_id, @users_repos)
              r.similar_users =  cluster.knn(k, users_repos[user_id])
              @similar_users_map << r
            end
          end
          threads.each { |t| t.join }
        end
      end
      @similar_users_map
    end
    
    def print_similar_users(fd=$stdout)
      similar_users_map.each do |recommendation|
        fd.puts "#{recommendation.user_id}:" + recommendation.similar_users.join(",")
      end
    end
    
    def recommendations
      similar_users_map.map do |similar_user_recommendations|
        similar_user_recommendations.ranked_repos
      end
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
    
    def similar_users=(similar_users_vectors)
      @similar_users = similar_users_vectors.map { |user| user.doc.name }
    end
    
    def similar_users_ids=(similar_users_ids)
      @similar_users = similar_users_ids
    end
    
    def ranked_repos
      already_watching = @users_repos[@user_id] || []
      watched_by_similar_users = Hash.new {0}
      @similar_users.each do |user|
        @users_repos[user].each do |repo|
          watched_by_similar_users[repo] += 1 unless already_watching.include?(repo)
        end
      end
      watched_by_similar_users
    end
    
  end
end

NNCB = NearestNeighborsClustersBench

