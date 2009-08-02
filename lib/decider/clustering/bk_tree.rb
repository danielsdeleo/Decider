# encoding: UTF-8

module Decider
  module Clustering
    class BkTree
      
      def root
        @root
      end
      
      def insert(name, vector)
        return @root = Node.new(name, vector) unless root
        
        @root.attach(Node.new(name, vector))
      end
      
      def nearest_neighbors(k, limit, target_vector)
        nodes_to_test = [@root]
        neighbors = []
        while node = nodes_to_test.shift
          distance_to_node = node.vector.distance(target_vector)
          neighbors << node if distance_to_node <= limit
          nodes_to_test += node.children_in_range(limit, distance_to_node)
        end
        neighbors
      end
      
      class Node
        attr_reader :name, :vector, :children
        
        def initialize(name, vector)
          @name, @vector = name, vector
          @children = {}
        end
        
        def attach(subnode)
          distance = @vector.distance(subnode.vector)
          if equidistant_child = @children[distance]
            equidistant_child.attach(subnode)
          else
            @children[distance] = subnode
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

      end
      
    end
  end
end
