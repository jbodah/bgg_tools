require 'lib/raw_init'

module BggTools
  class SearchResultItem
    include BggTools::RawInit

    def item_rank
      @raw.css('a[@name]').attr('name').value.to_i
    end

    def item_name
      @raw.css('a.primary').inner_html
    end

    def item_id
      @raw.css('a.primary').attr('href').value.split('/')[2]
    end

    def item_bcc_link
      "[thing=#{item_id}][/thing]"
    end
  end
end
