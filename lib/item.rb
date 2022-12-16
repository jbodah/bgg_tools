require 'lib/raw_init'

module BggTools
  class Item
    include BggTools::RawInit

    def name
      raw.attr("name")
    end

    def id
      raw.attr("objectid")
    end
  end
end
