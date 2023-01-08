module BggTools
  class Search
    def self.by_designer(designer_id:)
      raw_games = BggTools::API.search_games_by_designer(designer_id: designer_id)
      raw_games.map do |g|
        BggTools::SearchResultItem.new(g)
      end
    end
  end
end
