Enumerable.module_eval do
  def index_by(&blk)
    self.map(&blk).zip(self).to_h
  end

  def count_by(&blk)
    acc = {}
    self.each do |el|
      key = blk.call(el)
      acc[key] ||= 0
      acc[key] += 1
    end
    acc
  end

  def group_by_and_repack(&blk)
    acc = {}
    self.each do |el|
      key, pack = blk.call(el)
      acc[key] ||= []
      acc[key] << pack
    end
    acc
  end

  def to_items
    @to_items ||=
      begin
        items = self.map(&:item_id).uniq.each_slice(100).flat_map do |slice|
          doc = BggTools::API.download_things(item_ids: slice)
          doc.xpath('.//items/item').map do |raw_item|
            BggTools::Item.new(raw_item)
          end
        end

        self.each do |thing|
          thing.item = items.find { |i| i.item_id.to_i == thing.item_id.to_i }
        end

        items
      end
  end


  def pipe_to_list(list)
    list.add_all_items(self)
  end
end

Object.class_eval do
  def in?(enum)
    enum.include?(self)
  end

  def not_in?(enum)
    !in?(enum)
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

  def median
    sorted = self.sort

    if self.size % 2 == 1
      sorted[self.size/2]
    else
      (sorted[self.size/2] + sorted[(self.size-1)/2]) / 2.0
    end
  end

  def histogram
    self.reduce({}) { |acc, el| acc[el] ||= 0; acc[el] += 1; acc }.sort.to_h
  end
end
