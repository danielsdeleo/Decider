# encoding: UTF-8

module Decider
  module Clustering
    
    class Tree
      
      def initialize
        @root_node = Node.new(:root, [0])
      end
      
      def root
        @root_node
      end
      
      def insert(name, vector)
        @root_node.attach(Node.new(name, vector))
      end
      
      def to_formatted_s(*args)
        @root_node.to_formatted_s(0, *args)
      end
      
    end
    
    class Node
      include Vectorize
      
      attr_accessor :parent, :children, :vector, :foreign_id, :name
      
      N = 2
      
      def initialize(name, vector)
        @name, @children, @vector = name.to_s, [], vector
      end
      
      def attach(node)
        if children.size >= N
          @children << create_subnode(node)
        else
          node.parent = self
          @children << node
        end
        self
      end
      
      def create_subnode(node)
        closest_child = @children.delete_at(index_of_child_closest_to(node))
        avg_vector = closest_child.vector.average(node.vector)
        subnode = self.class.new(subnode_name(closest_child, node), avg_vector)
        subnode.attach(closest_child).attach(node)
      end
      
      def index_of_child_closest_to(node)
        index_of_closest_node, best_distance_measure = 0, 0.0
        @children.size.times do |i|
          distance_measure = @children[i].vector.closeness(node.vector)
          if distance_measure > best_distance_measure
            best_distance_measure = distance_measure
            index_of_closest_node = i
          end
        end
        index_of_closest_node
      end
      
      def <<(node)
        @children << node
      end
      
      def leaf?
        @children.empty?
      end
      
      def to_formatted_s(depth=0, opts={})
        str = ""
        if depth == 0
          str << "(root)\n"
        else
          (depth - 1).times { |i| str << "|  " }
          str << ("|--" + name)
          str = str.ljust(60) + vector.inspect if opts[:include_vectors]
          str << "\n"
        end
        unless leaf?
          children.each { |c| str << c.to_formatted_s(depth + 1, opts) }
        end
        str
      end
      
      private
      
      def subnode_name(node1, node2)
        node1.name.split("::").first + "::" + node2.name.split("::").last
      end
      
    end
  end
end
