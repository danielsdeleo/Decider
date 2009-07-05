# encoding: UTF-8

module Math
  
  def variance(population, opts={:sample=>false})
    n = 0
    mean = 0.0
    s = 0.0
    population.each { |x|
      n = n + 1
      delta = x - mean
      mean = mean + (delta / n)
      s = s + delta * (x - mean)
    }
    # if you want to calculate std deviation
    # of a sample change this to "s / (n-1)"
    return opts[:sample] ? s / (n - 1.0) : s / n
  end
  
  # calculate the standard deviation of a population
  # accepts: an array, the population
  # returns: the standard deviation
  def stddev(population, opts={:sample=>false})
    sqrt(variance(population, opts))
  end
  

  def avg(pop)
    total = pop.inject(0) { |sum, n| sum + n }
    total.to_f / pop.count.to_f
  end
  
  module_function :variance, :avg, :stddev
  
end