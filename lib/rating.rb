require 'lib/raw_init'

module BggTools
  class Rating
    include BggTools::RawInit

    def rating_to_bgcolor
      collection_rating.xpath(".//div[@style]")[0].attr("style").split(":")[1][0..-2]
    end

    def rating_bcc
      "[B][BGCOLOR=#{rating_to_bgcolor}] #{rating.to_i} [/BGCOLOR][/B]"
    end

    def rating
      collection_rating.css('.ratingtext')[0]&.inner_html&.to_f || 0.0
    end

    def comment
      collection_comment.css('div').find { |x| x.attr('id').start_with? 'results_comment' }.inner_html.strip.gsub('<br>', "\n")
    end

    def item_year
      begin
        collection_objectname.xpath('.//span[@class="smallerfont dull"]').inner_html[1..-2]
      rescue => e
        nil
      end
    end

    def item_name
      collection_objectname.xpath(".//a")[0].inner_html
    end

    def item_id
      relurl = collection_objectname.css('.primary')[0].attr('href')
      relurl.split('/')[2]
    end

    private

    def tds
      raw.xpath(".//td")
    end

    def collection_objectname
      tds.find { |td| td.attr("class").rstrip == "collection_objectname" }
    end

    def collection_comment
      tds.find { |td| td.attr("class").rstrip == "collection_comment" }
    end

    def collection_rating
      tds.find { |td| td.attr("class").rstrip == "collection_rating" }
    end
  end
end
