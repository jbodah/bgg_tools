require 'lib/raw_init'

module BggTools
  class Item
    include BggTools::RawInit

    def self.find(item_id:)
      raw = BggTools::API.download_thing(item_id: item_id)
      BggTools::Item.new(raw)
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

    def avg_rating
      @raw.xpath('.//ratings/average').first.attr('value').to_f
    end

    def bayes_avg_rating
      @raw.xpath('.//ratings/bayesaverage').first.attr('value').to_f
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
