# encoding: UTF-8

module Decider
  module Vectors
    class AbstractBase
      
      def closeness(other)
        raise NotImplementedError.new(self.class, :difference_coefficient)
      end
      
      def average(other)
        raise NotImplementedError.new(self.class, :average)
      end
      
    end
  end
end
