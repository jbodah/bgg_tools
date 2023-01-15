require 'lib/raw_init'

module BggTools
  class SearchResultItem
    include BggTools::RawInit

    def item_rank
      rank_node = @raw.css('td.collection_rank')
      if rank_node.inner_html.strip == "N/A"
        -1
      else
        rank_node.css('a[@name]').attr('name').value.to_i
      end
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

    def geekrating
      @raw.css('td.collection_bggrating')[0].inner_html.strip.to_f
    end

    def avg_rating
      @raw.css('td.collection_bggrating')[1].inner_html.strip.to_f
    end

    def num_voters
      @raw.css('td.collection_bggrating')[2].inner_html.strip.to_i
    end
  end
end
