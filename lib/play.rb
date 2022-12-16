require 'lib/raw_init'

module BggTools
  class Play
    include BggTools::RawInit

    def item
      BggTools::Item.new(raw.xpath(".//item")[0])
    end

    def date
      raw.attr("date")
    end
  end
end
