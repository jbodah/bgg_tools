module BggTools
  class Guild
    def initialize(guild_id:)
      @guild_id = guild_id
    end

    def members
      users = BggTools::API.download_guild_users(guild_id: @guild_id)
      users.map { |u| BggTools::User.new(user_id: u) }
    end
  end
end
