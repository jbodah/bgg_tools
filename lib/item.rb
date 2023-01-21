require 'lib/raw_init'

module BggTools
  class Item
    include BggTools::RawInit

    def self.find(item_id:)
      raw = BggTools::API.download_thing(item_id: item_id)
      BggTools::Item.new(raw)
    end

    def url
      "https://boardgamegeek.com/boardgame/#{id}"
    end

    def bcc_link
      "[thing=#{id}][/thing]"
    end

    def id
      @raw.attr('id')
    end

    def item_id
      id
    end

    def thumbnail
      @raw.xpath('.//item/thumbnail').inner_html
    end

    def name
      @raw.xpath('.//name[@type="primary"]').first.attr('value')
    end

    def description
      @raw.xpath('.//description').first.inner_html
    end

    def yearpublished
      @raw.xpath('.//yearpublished').first.attr('value').to_i
    end

    def minplayers
      @raw.xpath('.//minplayers').first.attr('value').to_i
    end

    def maxplayers
      @raw.xpath('.//maxplayers').first.attr('value').to_i
    end

    # poll suggested_numplayers
    def suggested_numplayers
      @suggested_numplayers ||=
        @raw.xpath('.//poll[@name="suggested_numplayers"]/results').reduce({}) do |acc, results|
          acc[results.attr('numplayers')] = {
            best: results.xpath('.//result[@value="Best"]').attr('numvotes').value.to_i,
            recommended: results.xpath('.//result[@value="Recommended"]').attr('numvotes').value.to_i,
            not_recommended: results.xpath('.//result[@value="Not Recommended"]').attr('numvotes').value.to_i,
          }
          acc
        end
    end

    def recommended_with?(n)
      s = suggested_numplayers[n.to_s]
      return false unless s
      (s[:recommended] + s[:best]) > s[:not_recommended]
    end

    def best_with?(n)
      s = suggested_numplayers[n.to_s]
      return false unless s
      s[:best] > (s[:best] + s[:not_recommended])
    end

    def play_time
      @raw.xpath('.//playingtime').first.attr('value').to_i
    end

    def min_play_time
      @raw.xpath('.//minplaytime').first.attr('value').to_i
    end

    def max_play_time
      @raw.xpath('.//maxplaytime').first.attr('value').to_i
    end

    def categories
      @raw.xpath('.//link[@type="boardgamecategory"]').map { |l| l.attr('value') }
    end

    def mechanics
      @raw.xpath('.//link[@type="boardgamemechanic"]').map { |l| l.attr('value') }
    end

    def families
      @raw.xpath('.//link[@type="boardgamefamily"]').map { |l| l.attr('value') }
    end

    def num_ratings
      @raw.xpath('.//usersrated').first.attr('value').to_i
    end

    def num_voters
      num_ratings
    end

    def avg_rating
      @raw.xpath('.//ratings/average').first.attr('value').to_f
    end

    def bayes_avg_rating
      @raw.xpath('.//ratings/bayesaverage').first.attr('value').to_f
    end

    def geekrating
      bayes_avg_rating
    end

    def rank
      @raw.xpath('.//rank[@name="boardgame"]').first.attr('value').to_i
    end

    def rating_stddev
      @raw.xpath('.//stddev').first.attr('value').to_f
    end

    # def median_rating
    #   @raw.xpath('.//median').first.attr('value').to_f
    # end

    def num_owned
      @raw.xpath('.//owned').first.attr('value').to_i
    end

    def num_for_trade
      @raw.xpath('.//trading').first.attr('value').to_i
    end

    def num_want
      @raw.xpath('.//wanting').first.attr('value').to_i
    end

    def num_wishlist
      @raw.xpath('.//wishing').first.attr('value').to_i
    end

    def num_comments
      @raw.xpath('.//numcomments').first.attr('value').to_i
    end

    def weight
      @raw.xpath('.//averageweight').first.attr('value').to_f
    end
  end
end
