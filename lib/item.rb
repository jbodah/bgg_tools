require 'lib/raw_init'

module BggTools
  class Item
    include BggTools::RawInit

    def self.from_id(item_id:)
      raw = BggTools::API.download_thing(item_id: item_id)
      BggTools::Item.new(raw)
    end

    def thumbnail
      @raw.xpath('.//item/thumbnail').inner_html
    end

    def name
      @raw.xpath('.//name[@type="primary"]').first.attr('value')
    end
  end
end
