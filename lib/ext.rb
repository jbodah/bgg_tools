Enumerable.module_eval do
  def index_by(&blk)
    self.map(&blk).zip(self).to_h
  end
end

Object.class_eval do
  def in?(enum)
    enum.include?(self)
  end
end

Array.class_eval do
  def std_dev
    mean = self.mean
    sum_of_sq_mean_dist = self.map do |point|
      (point - mean)*(point - mean)
    end.sum
    Math.sqrt(sum_of_sq_mean_dist.to_f / self.size)
  end

  def mean
    self.sum.to_f / self.size
  end
end
