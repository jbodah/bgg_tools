require 'lib/raw_init'

module BggTools
  class GeeklistEntry
    include BggTools::RawInit

    def entry_id
      @raw.attr('id')
    end

    def item_id
      @raw.attr('objectid')
    end

    def item_name
      @raw.attr('objectname')
    end

    def username
      @raw.attr('username')
    end

    def postdate
      @raw.attr('postdate')
    end

    def body
      @raw.css('body').inner_html
    end
  end
end
