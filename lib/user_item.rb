module BggTools
  class UserItem
    attr_accessor :user, :item

    def initialize(user:, item:, rating: nil, plays: nil)
      @user = user
      @item = item
      @rating = rating
      @plays = plays
    end

    def rated?
      rating && rating.to_i > 0
    end

    def rating
      @rating ||= user.ratings_by_item_id[item.id]
    end

    def owned?
      !!user.owned.find { |r| r.item_id == item.id }
    end

    def played?(since: '2010-01-01')
      plays(since: since).any?
    end

    def plays(since: '2010-01-01')
      @plays ||= user.plays_by_item_id(since: since)[item.id] || []
    end

    def item_id
      @item.id
    end
  end
end

BggTools::UserItem.include(BggTools::Itemable)
