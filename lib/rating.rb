require 'lib/raw_init'
require 'lib/itemable'
require 'date'

module BggTools
  class Rating
    include BggTools::RawInit

    def style_grimwoldish
      <<~EOF
      [size=12][b]#{item.bcc_link} - #{rating_bcc}[/b][/size]
      #{item.thumbnail_bcc(size: "square inline")}
      EOF
    end

    def rating_to_bgcolor
      collection_rating.xpath(".//div[@style]")[0].attr("style").split(":")[1][0..-2]
    end

    def rating_bcc
      "[B][BGCOLOR=#{rating_to_bgcolor}] #{rating.to_i} [/BGCOLOR][/B]"
    end

    def rating
      collection_rating.css('.ratingtext')[0]&.inner_html&.to_f || 0.0
    end

    def to_i
      rating
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

    def date_commented
      Date.parse(raw.css('.fr').inner_html.strip).to_s rescue '1900-01-01'
    end

    def date_rated
      text = collection_rating.css('.sf').inner_html
      month = text[0..2]
      year = text[-4..-1]
      case month
      when "Jan" then "#{year}-01-01"
      when "Feb" then "#{year}-02-01"
      when "Mar" then "#{year}-03-01"
      when "Apr" then "#{year}-04-01"
      when "May" then "#{year}-05-01"
      when "Jun" then "#{year}-06-01"
      when "Jul" then "#{year}-07-01"
      when "Aug" then "#{year}-08-01"
      when "Sep" then "#{year}-09-01"
      when "Oct" then "#{year}-10-01"
      when "Nov" then "#{year}-11-01"
      when "Dec" then "#{year}-12-01"
      else
        raise month
      end
    end

    def update_comment(comment = nil)
      comment = yield(self.comment) if block_given?
      BggTools::API.update_comment(item_id: item_id, comment: comment, collid: raw.attr('id').sub(/^row_/, ''))
    end

    private

    def tds
      raw.xpath(".//td[@class]")
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

BggTools::Rating.include(BggTools::Itemable)
