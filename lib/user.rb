module BggTools
  class User
    attr_accessor :user_id

    def initialize(user_id:)
      @user_id = user_id
    end

    def ratings
      raw_ratings = BggTools::API.download_ratings(user_id: user_id)
      raw_ratings.map do |raw|
        BggTools::Rating.new(raw)
      end
    end

    def owned
      raw = BggTools::API.download_owned(user_id: user_id)
      raw.map do |raw|
        BggTools::Rating.new(raw)
      end
    end

    def plays(since:)
      raw_plays = BggTools::API.download_plays(user_id: user_id, since: since)
      raw_plays.map do |raw|
        BggTools::Play.new(raw)
      end
    end
  end
end
