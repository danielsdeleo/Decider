# encoding: UTF-8
require "forwardable"

module Decider
  module Clustering
    
    # A BK Tree to provide more efficient computation of nearest neighbors.
    # The wikipedia article on BK Trees kinda sucks, but this blog post is decent:
    # http://blog.notdot.net/2007/4/Damn-Cool-Algorithms-Part-1-BK-Trees
    class BkTree
      
      def root
        @root ||= nil
      end
      
      def insert(name, vector)
        return @root = Node.new(name, vector) unless root
        
        @root.attach(Node.new(name, vector))
      end
      
      # Finds all of the neighboring nodes within +limit+ distance
      # from +target_vector+
      def nearest_neighbors(limit, target_vector)
        find_nearest_neighbors(target_vector, :distance => limit)
      end
      
      # Finds the single nearest neighbor to +target_vector+
      def nearest_neighbor(target_vector)
        find_nearest_neighbors(target_vector, :results => 1).first
      end
      
      def k_nearest_neighbors(k, target_vector)
        find_nearest_neighbors(target_vector, :results => k)
      end
      
      alias :knn :k_nearest_neighbors
      
      def to_formatted_s
        root ? root.to_formatted_s : ""
      end
      
      def size
        root ? 1 + root.size : 0
      end
      
      private
      
      def find_nearest_neighbors(target_vector, opts={})
        nodes_to_test = [@root]
        results = Results.new(opts)
        while node = nodes_to_test.shift
          distance_to_node = node.vector.distance(target_vector)
          results[node] = distance_to_node
          nodes_to_test += node.children_in_range(results.distance_limit, distance_to_node)
        end
        results.to_a
      end
      
      class Results
        extend Forwardable
        def_delegators :@results, :values, :size
        
        def initialize(opts={})
          @max_results, @distance = opts[:results], opts[:distance]
          @results = {}
        end
        
        def []=(vector,distance)
          if !distance_limit || distance <= distance_limit
            @results[vector] = distance
            delete_worst if @max_results && @results.size > @max_results
          end
        end
        
        def distance_limit
          limit = @distance || values.first
          @results.each do |node, distance|
            limit = distance if limit && distance > limit
          end
          limit
        end
        
        def to_a
          @results.keys
        end
        
        private
        
        def delete_worst
          worst_node = @results.keys.first
          worst_distance = @results[worst_node]
          @results.each do |node, distance|
            if distance > worst_distance
              worst_node, worst_distance = node, distance
            end
          end
          @results.delete(worst_node)
        end
        
      end
      
      class Node
        attr_reader :name, :vector, :children
        
        def initialize(name, vector)
          @name, @vector = name, vector
          @children = {}
        end
        
        def attach(subnode)
          node_to_attach_to = self
          while node_to_attach_to
            distance = node_to_attach_to.vector.distance(subnode.vector)
            if equidistant_child = node_to_attach_to.children[distance]
              node_to_attach_to = equidistant_child
            else
              node_to_attach_to.children[distance] = subnode
              node_to_attach_to = nil
            end
          end
        end
        
        def to_formatted_s(depth=0)
          prefix = "  " * depth
          str = "#{name}:\n"
          @children.each do |distance, node|
            str << prefix + "#{distance} => #{node.to_formatted_s(depth + 1)}\n"
          end
          str
        end
        
        def children_in_range(center, distance)
          min, max = center - distance, center + distance
          min = 0 if min < 0
          @children.select { |k,v| k >= min && k <= max }.map do |kv_pair|
            kv_pair.last
          end
        end
        
        def size
          @children.size + @children.inject(0) { |sum, child| sum + child.last.size }
        end

      end
      
    end
  end
end
