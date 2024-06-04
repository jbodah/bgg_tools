module BggTools
  module Itemable
    def self.included(base)
      raise "#{base} must respond to :item_id" unless base.instance_method(:item_id)
    end

    def item
      @item
    end

    def item=(item)
      @item = item
    end

    def playstats(page: 1)
      BggTools::API.download_item_playstats(item_id: item_id, page: page)
    end

    # TODO: @jbodah 2023-02-19: other pages
    def play_counts
      _playcounts(playstats)
    end

    def num_unique_players
      last_page_num = 1
      playstats_first = playstats
      playstats_last_href = playstats_first.xpath('//a[@title="last page"]')[0]
      playstats_last_href = playstats_first.xpath('//a[@title="page 5"]')[0] if playstats_last_href.nil?
      playstats_last_href = playstats_first.xpath('//a[@title="page 4"]')[0] if playstats_last_href.nil?
      playstats_last_href = playstats_first.xpath('//a[@title="page 3"]')[0] if playstats_last_href.nil?
      playstats_last_href = playstats_first.xpath('//a[@title="page 2"]')[0] if playstats_last_href.nil?
      playstats_last = nil
      if playstats_last_href
        playstats_last_href = playstats_last_href.attr('href')
        last_page_num = playstats_last_href.split("/").last.to_i
        playstats_last = playstats(page: last_page_num)
      else
        playstats_last = playstats_first
      end
      (last_page_num - 1) * 100 + _playcounts(playstats_last).size
    end

    def nth_percentile_playcount(n)
      @nth_percentile_playcount ||= {}
      @nth_percentile_playcount[n] ||=
        begin
          nth_player = num_unique_players * n.to_f
          page_with_nth_player = (nth_player / 100.0).ceil
          playstats_with_nth_player = playstats(page: page_with_nth_player)
          position = nth_player.round - (100 * (page_with_nth_player - 1)) - 1
          _playcounts(playstats_with_nth_player)[position]
        end
    end

    def _playcounts(html_doc)
      html_doc.xpath('//table[@class="forum_table"]/tr')[1..-1].map { |p| p.xpath('td')[1].text.to_i }
    end

    def item_bcc_link
      "[thing=#{item_id}][/thing]"
    end

    def item_name
      item.name
    end
  end
end
