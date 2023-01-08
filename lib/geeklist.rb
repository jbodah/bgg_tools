require 'json'

module BggTools
  class Geeklist
    def initialize(list_id:)
      @list_id = list_id
      @idx = 1
    end

    def reset_idx
      @idx = 1
    end

    def add_all_items(tuples_or_item_ids)
      tuples_or_item_ids.each do |t_or_id|
        if t_or_id.is_a?(Array)
          id, body = t_or_id
          add_item(item_id: id, body: body)
        else
          add_item(item_id: t_or_id, body: "")
        end
      end
    end

    def add_item(idx: @idx, item_id:, body: "")
      json = {
        "item" => {"type" =>  "things", "id" =>  "#{item_id}" },
        "imageid" =>  nil,
        "imageOverridden" =>  false,
        "index" => idx,
        "body" => body,
        "rollsEnabled" => false
      }.to_json
      @idx += 1
      BggTools::API.http_post_json("https://api.geekdo.com/api/geeklists/#{@list_id}/listitems", json: json)
    end

    # https://api.geekdo.com/api/listitems?listid=302917&page=1
    # PATCH to https://api.geekdo.com/api/listitems/9411421 to update
  end
end
