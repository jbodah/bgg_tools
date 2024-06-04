require 'lib/raw_init'

module BggTools
  class Play
    include BggTools::RawInit

    def playitem
      BggTools::PlayItem.new(raw.xpath(".//item")[0])
    end

    def item_id
      raw.xpath(".//item")[0].attr("objectid")
    end

    def date
      raw.attr("date")
    end
  end
end

BggTools::Play.include(BggTools::Itemable)
