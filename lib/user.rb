module BggTools
  class User
    attr_accessor :user_id

    def initialize(user_id: "hiimjosh")
      @user_id = user_id
    end

    def ratings
      @ratings ||=
        begin
          raw_ratings = BggTools::API.download_ratings(user_id: user_id)
          raw_ratings.map do |raw|
            BggTools::Rating.new(raw)
          end
        end
    end

    def ratings_by_item_id
      @ratings_by_item_id ||= ratings.index_by(&:item_id)
    end

    def owned
      @owned ||=
        begin
          raw = BggTools::API.download_owned(user_id: user_id)
          ratings = raw.map do |raw|
            BggTools::Rating.new(raw)
          end
          ratings.to_items
          ratings.map { |r| BggTools::UserItem.new(user: self, rating: r, item: r.item) }
        end
    end

    def plays(since: '2010-01-01')
      @plays ||=
        begin
          raw_plays = BggTools::API.download_plays(user_id: user_id, since: since)
          raw_plays.map do |raw|
            BggTools::Play.new(raw)
          end
        end
    end

    def plays_by_item_id(since: '2010-01-01')
      @plays_by_item_id ||= plays(since: since).group_by(&:item_id)
    end

    def played(since: '2010-01-01')
      @played ||=
        begin
          plays(since: since).to_items
          plays.group_by(&:item).map { |item, ps| BggTools::UserItem.new(user: self, plays: ps, item: item) }
        end
    end

    def rated
      @rated ||=
        begin
          ratings.to_items
          ratings.map { |r| BggTools::UserItem.new(user: self, rating: r, item: r.item) }
        end
    end
  end
end
