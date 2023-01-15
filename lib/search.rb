module BggTools
  class Search
    def self.by_designer(designer_id:)
      raw_games = BggTools::API.search_games(designer_id: designer_id)
      raw_games.map do |g|
        BggTools::SearchResultItem.new(g)
      end
    end

    def self.by_rank(max_pages: Float::INFINITY)
      raw_games = BggTools::API.browse_games_by_rank(max_pages: max_pages)
      raw_games.map do |g|
        BggTools::SearchResultItem.new(g)
      end
    end

    def self.search(**args)
      raw_games = BggTools::API.search_games(**args)
      raw_games.map do |g|
        BggTools::SearchResultItem.new(g)
      end
    end
  end
end
