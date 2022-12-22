require 'json'

module BggTools
  class Geeklist
    def initialize(list_id:, auth:)
      @list_id = list_id
      @auth = auth
      @idx = 1
    end

    def reset_idx
      @idx = 1
    end

    def add_item(item_id:, body:)

      json = {
        "item" => {"type" =>  "things", "id" =>  "#{item_id}" },
        "imageid" =>  nil,
        "imageOverridden" =>  false,
        "index" => @idx,
        "body" => body,
        "rollsEnabled" => false
      }.to_json
      auth_header = "Authorization: GeekAuth #{@auth}"

      @idx += 1

      cmd = ["curl", "-X", "POST", "-d", json, "-H", auth_header, "https://api.geekdo.com/api/geeklists/#{@list_id}/listitems"]
      system *cmd
    end

    # https://api.geekdo.com/api/listitems?listid=302917&page=1
    # PATCH to https://api.geekdo.com/api/listitems/9411421 to update
  end
end
