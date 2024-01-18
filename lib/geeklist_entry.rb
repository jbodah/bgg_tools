require 'lib/raw_init'
require 'lib/itemable'

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

    def objecttype
      @raw.attr('objecttype')
    end

    def subtype
      @raw.attr('subtype')
    end

    def objectname
      @raw.attr('objectname')
    end

    def objectid
      @raw.attr('objectid')
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

    def bcc_link
      "[listitem=#{entry_id}][/listitem]"
    end
  end
end

BggTools::GeeklistEntry.include(BggTools::Itemable)
