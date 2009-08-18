require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + "/../../benchmark/github_contest"

describe GithubContest::Data do
  
  it "should use the singleton pattern" do
    lambda {GithubContest::Data.new}.should raise_error
  end
  
  it "should load the sample data and test set" do
    GithubContest::Data.instance.should_receive(:load_sample_data)
    GithubContest::Data.instance.should_receive(:load_test_data)
    GithubContest::Data.load!
    GithubContest::Data.data_loaded?.should be_true
  end
  
  it "should give the repos watched by a user" do
    GithubContest::Data.instance.should_receive(:users_repos).and_return({123=>[12,34,56,78]})
    GithubContest::Data.repos_watched_by(123).should == [12,34,56,78]
  end
  
  it "should give the watchers of a repo" do
    GithubContest::Data.instance.should_receive(:repos_watchers).and_return({866 =>[123,456,789]})
    GithubContest::Data.users_watching(866).should == [123,456,789]
  end
  
  it "should forward #each_user to instance#users_repos" do
    users_repos_hash = mock("users_repos_hash")
    users_repos_hash.should_receive(:each)
    GithubContest::Data.instance.should_receive(:users_repos).and_return(users_repos_hash)
    GithubContest::Data.each_user { |user, repos| "whatever" }
  end
  
  it "should forward #each_repo to instance#each_repo" do
    repos_watchers_hsh = mock("repos_watchers_hsh")
    repos_watchers_hsh.should_receive(:each)
    GithubContest::Data.instance.should_receive(:repos_watchers).and_return(repos_watchers_hsh)
    GithubContest::Data.each_repo { |user, repos| "whatever" }
  end
  
  it "should forward test_users to instance#test_users" do
    GithubContest::Data.instance.should_receive(:test_users)
    GithubContest::Data.test_users
  end
  
  it "should give the ids of all repos as an array" do
    GithubContest::Data.instance.stub!(:repos_watchers).and_return({123=>[23],456=>[56],789=>[89]})
    GithubContest::Data.all_repos.should include(123,456,789)
  end
  
  it "should give the 10 most popular repos excluding ones already watched by a given user" do
    popular_repos = {1=>10,2=>20,3=>30,4=>40,5=>50,6=>60,7=>70,8=>80,9=>90,10=>100,11=>110,12=>120}
    GithubContest::Data.instance.stub(:repo_popularity).and_return(popular_repos)
    GithubContest::Data.stub!(:repos_watched_by).with(40998).and_return([12,10])
    GithubContest::Data.ten_most_popular_remaining_for(40998).should == [11,9,8,7,6,5,4,3,2,1].reverse
  end
end

describe GithubContest::SimilarUsers do
  
  before do
    @similar_users = GithubContest::SimilarUsers.new(40998)
  end
  
  it "should store the id of the test user" do
    @similar_users.test_user.should == 40998
  end
  
  it "should store user ids with their distance metrics" do
    @similar_users.user(:id => 123, :metric => 10)
    @similar_users.user(:id => 456, :metric => 35)
    @similar_users.users_with_metrics.should == {123 => 10, 456 => 35}
  end
  
  it "should store several user ids with metrics at once" do
    # results are {user_id => distance, ...}
    knn_results = {123 => 866, 456 => 678}
    @similar_users.users(knn_results)
    @similar_users.users_with_metrics.should equal knn_results
  end
  
  it "should convert itself into recommended repos" do
    # results are {user_id => distance, ...}
    knn_results = {123 => 866, 456 => 678}
    @similar_users.users(knn_results)
    GithubContest::Data.stub!(:repos_watched_by).with(123).and_return([321,32])
    GithubContest::Data.stub!(:repos_watched_by).with(456).and_return([654,65])
    recommendations = @similar_users.to_recommended_repos
    recommendations.test_user.should == 40998
    # metrics for users are passed on to the repos
    recommendations.repos_with_metrics.should == {321=>[866],32=>[866],654=>[678],65=>[678]}
  end
  
  it "should convert to a string with the format userid:user,metric;user,metric; etc." do
    @similar_users.user(:id => 123, :metric => 10)
    @similar_users.user(:id => 456, :metric => 35)
    similar_user_str = @similar_users.to_s
    similar_user_str.should match(/^40998\:/)
    similar_user_str.should match(/123=>10;/)
    similar_user_str.should match(/456=>35;/)
  end
  
  it "should validate the format of a string it might load" do
    GithubContest::SimilarUsers.invalid_string?("123:45=>67;89=>91;").should be_false
    GithubContest::SimilarUsers.invalid_string?("123:45=>67.76;89=>91.19;").should be_false
    GithubContest::SimilarUsers.invalid_string?("123:45=>67;89=>91").should be_true
    GithubContest::SimilarUsers.invalid_string?("123:45=67;89=>91;").should be_true
    GithubContest::SimilarUsers.invalid_string?("12345=>67;89=>91;").should be_true
    GithubContest::SimilarUsers.invalid_string?("abc123:45=>67;89=>91;").should be_true
  end
  
  it "should load a string of the same format used by to_s" do
    similar_users = GithubContest::SimilarUsers.load_string("40998:123=>10;456=>35;\n")
    similar_users.users_with_metrics.should == {123=>10,456=>35}
    similar_users.test_user.should == 40998
  end
  
  it "should load a string of the same format used by to_s when the metric is a float" do
    similar_users = GithubContest::SimilarUsers.load_string("40998:123=>10.1;456=>35.85;\n")
    similar_users.users_with_metrics.should == {123=>10.1,456=>35.85}
    similar_users.test_user.should == 40998
  end
  
end

describe GithubContest::RecommendedRepos do
  
  before do
    @recommended = GithubContest::RecommendedRepos.new(234)
  end
  
  it "should store the test user or repo id" do
    @recommended.test_repo.should == 234
    @recommended.test_user.should == 234
  end
  
  it "should store the repo ids with their distance metrics" do
    @recommended.consider_repo(:id => 866, :metric => 5)
    @recommended.consider_repo(:id => 7, :metric => 23)
    @recommended.repos_with_metrics.should == {866 => [5], 7 => [23]}
  end
  
  it "should rank the repos as 1/metric" do
    @recommended.consider_repo(:id => 866, :metric => 1000)
    @recommended.consider_repo(:id => 866, :metric => 500)
    @recommended.consider_repo(:id => 23, :metric => 10)
    @recommended.ranked_repos.should == {866 => ((1.0/1001.0) + (1.0/501.0)), 23 => (1.0/11.0)}
  end
  
  it "should store more than one repo with its distance metric at a time" do
    # knn results format: similar_repo_id => similar_repo_distance
    knn_results = {866 => 3, 45=>234}
    @recommended.may_include(knn_results)
    @recommended.repos_with_metrics.should == {866 => [3], 45=>[234]}
  end
  
  it "should remove recommended repos already watched by a user" do
    @recommended.consider_repo(:id => 866, :metric => 1000)
    @recommended.consider_repo(:id => 866, :metric => 500)
    @recommended.consider_repo(:id => 23, :metric => 10)
    GithubContest::Data.stub!(:repos_watched_by).with(40998).and_return([866])
    @recommended.repos_with_metrics(:exclude_users_repos=>40998).should == {23=>[10]}
    @recommended.ranked_repos(:exclude_users_repos=>40998).should == {23 => (1.0/11.0)}
  end
  
  it "should select the ten best repos" do
    knn_results = {1=>11,2=>22,3=>33,4=>44,5=>55,6=>66,7=>77,8=>88,9=>99,10=>110,11=>121,12=>132,13=>1313,14=>1414}
    GithubContest::Data.stub(:repos_watched_by).with(40998).and_return([2])
    @recommended.may_include(knn_results)
    @recommended.ten_best_repos_for(40998).should include(1,3,4,5,6,7,8,9,10,11)
  end
  
  it "should pad the best repos with the most popular if there are less than 10" do
    knn_results = {1=>11,2=>22,3=>33,4=>44}
    GithubContest::Data.stub(:repos_watched_by).with(40998).and_return([])
    GithubContest::Data.stub!(:ten_most_popular_remaining_for).with(40998).and_return([100,90,80,70,60,50,40,30,20,10])
    @recommended.may_include(knn_results)
    @recommended.recommendations_for(40998).should include(1,2,3,4,10,20,30,40,50,60)
  end
  
  it "should emit recommendations as string of the form user_id:repo1,repo2..repo10" do
    recommended_repos = (1..10).to_a
    @recommended.stub!(:recommendations_for).with(40998).and_return(recommended_repos)
    @recommended.emit_recommendations_for(40998).should == "40998:1,2,3,4,5,6,7,8,9,10"
  end
  
  it "should convert to a string of the form test_subject_id:repo1=>metric1a,metric1b;repo2=>metric2a,metric2b;" do
    @recommended.consider_repo(:id => 866, :metric => 1000)
    @recommended.consider_repo(:id => 866, :metric => 500)
    @recommended.consider_repo(:id => 23, :metric => 10)
    as_a_string = @recommended.to_s # "234:866=>1000,500;23=>10;"
    as_a_string.should match(/^234:/)
    as_a_string.should match(/866=>1000,500;/)
    as_a_string.should match(/23=>10;/)
  end
  
  it "should load strings of the form emitted by #to_s" do
    recommended = GithubContest::RecommendedRepos.load_string("234:866=>1000,500.678;23=>10;")
    recommended.should be_an_instance_of GithubContest::RecommendedRepos
    recommended.test_repo.should == 234
    recommended.repos_with_metrics.should == {866=>[1000,500.678],23=>[10]}
  end
end

describe GithubContest::UsersCluster do
  
  it "should have a nearest neighbors cluster" do
    wants_verbatim = mock("repos_vector")
    wants_verbatim.should_receive(:verbatim)
    Decider::Clustering::NearestNeighbors.should_receive(:new).with(:the_vector_type).and_yield(wants_verbatim)
    GithubContest::UsersCluster.new(:vector_type => :the_vector_type)
  end
    
  context "after initialized" do
    
    before do
      @users_cluster = GithubContest::UsersCluster.new
    end

    it "should load the users-watches data into the cluster" do
      GithubContest::Data.instance.stub!(:users_repos).and_return({123=>[123],456=>[456],789=>[789]})
      @users_cluster.cluster.should_receive(:push).with(123,[123])
      @users_cluster.cluster.should_receive(:push).with(456,[456])
      @users_cluster.cluster.should_receive(:push).with(789,[789])
      @users_cluster.load!
    end
    
    it "should trigger the building of the BkTree" do
      @users_cluster.cluster.should_receive(:tree)
      @users_cluster.build
    end
    
    it "should find the users similar to a test user by KNN" do
      vector_for_user_40998 = [866,123,456]
      doc12 = mock("doc12")
      doc12.stub!(:name).and_return(12)
      doc34 = mock("doc34")
      doc34.stub!(:name).and_return(34)
      doc56 = mock("doc56")
      doc56.stub!(:name).and_return(56)
      knn_results = {doc12 => 5, doc34 => 10, doc56 => 15}
      GithubContest::Data.stub!(:repos_watched_by).with(40998).and_return(vector_for_user_40998)
      @users_cluster.cluster.should_receive(:knn).with(25, vector_for_user_40998, :include_scores => true).and_return(knn_results)
      similar_users = @users_cluster.users_similar_to(40998, :k=>25)
      similar_users.should be_an_instance_of(GithubContest::SimilarUsers)
      similar_users.test_user.should == 40998
      similar_users.users_with_metrics.should == {12=>5,34=>10,56=>15}
    end
    
    it "should convert similar users to recommendations" do
      similar_users = mock("similar_users")
      similar_users.stub!(:to_recommended_repos).and_return(:surprise)
      all_similar_users = (1..10).map { similar_users }
      @users_cluster.instance_variable_set(:@all_similar_users, all_similar_users)
      @users_cluster.recommendations.should == (1..10).map {:surprise}
    end
    
  end
  
end

describe GithubContest::ReposCluster do
  
  it "should have a nearest neighbors cluster" do
    wants_verbatim = mock("repos_vector")
    wants_verbatim.should_receive(:verbatim)
    Decider::Clustering::NearestNeighbors.should_receive(:new).with(:the_vector_type).and_yield(wants_verbatim)
    GithubContest::ReposCluster.new(:vector_type => :the_vector_type)
  end
    
  context "after initialized" do
    
    before do
      @repos_cluster = GithubContest::ReposCluster.new
    end
    
    it "should load the repo-watchers data into the cluster" do
      GithubContest::Data.instance.stub!(:repos_watchers).and_return({123=>[123],456=>[456],789=>[789]})
      @repos_cluster.cluster.should_receive(:push).with(123,[123])
      @repos_cluster.cluster.should_receive(:push).with(456,[456])
      @repos_cluster.cluster.should_receive(:push).with(789,[789])
      @repos_cluster.load!
    end
    
    it "should trigger the building of the BKTree" do
      @repos_cluster.cluster.should_receive(:tree)
      @repos_cluster.build
    end
    
    it "should find the k most similar repos to a given repo" do
      vector_for_repo_866 = [123,45,678]
      doc123 = mock("doc123")
      doc123.stub!(:name).and_return(123)
      doc45 = mock("doc45")
      doc45.stub!(:name).and_return(45)
      doc678 = mock("doc678")
      doc678.stub!(:name).and_return(678)
      knn_results = {doc123 => 10,doc45=>15,doc678=>20}
      GithubContest::Data.stub!(:users_watching).with(866).and_return(vector_for_repo_866)
      @repos_cluster.cluster.should_receive(:knn).with(10, vector_for_repo_866, :include_scores=>true).and_return(knn_results)
      similar_repos = @repos_cluster.repos_similar_to(866, :k=>10)
      similar_repos.should be_an_instance_of(GithubContest::RecommendedRepos)
      similar_repos.test_repo.should == 866
      similar_repos.repos_with_metrics.should == {123 => [10], 45=>[15],678=>[20]}
    end
    
  end
end
    