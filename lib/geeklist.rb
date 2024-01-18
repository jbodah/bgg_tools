require 'json'

module BggTools
  class Geeklist
    def initialize(list_id:, idx: 1)
      @list_id = list_id
      @idx = idx
    end

    def reset_idx
      @idx = 1
    end

    def add_all_items(tuples_or_item_ids)
      tuples_or_item_ids.each do |t_or_id|
        if t_or_id.is_a?(Array)
          id, body = t_or_id
          add_item(item_id: id, body: body)
        elsif t_or_id.respond_to?(:item_id)
          add_item(item_id: t_or_id.item_id, body: "")
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
      BggTools::API.http_post("https://api.geekdo.com/api/geeklists/#{@list_id}/listitems", data: json)
    end

    def link_to_entry(entry)
      "https://boardgamegeek.com/geeklist/#{@list_id}?itemid=#{entry.entry_id}##{entry.entry_id}"
    end

    def download
      @raw = BggTools::API.download_list(list_id: @list_id)
    end

    def entries
      download.xpath('//item').map { |i| BggTools::GeeklistEntry.new(i) }
    end

    # https://api.geekdo.com/api/listitems?listid=302917&page=1
    # PATCH to https://api.geekdo.com/api/listitems/9411421 to update
  end
end
