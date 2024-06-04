require 'lib/raw_init'
require 'lib/itemable'
require 'htmlentities'

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
      "[thing=#{id}]#{name}[/thing]"
    end

    def id
      @raw.attr('id') || @raw.xpath('.//item').attr('id').value
    end

    def item_id
      id
    end

    def thumbnail
      @raw.xpath('.//thumbnail').inner_html
    end

    def thumbnail_bcc(size:)
      "[imageid=#{thumbnail.split('/')[-1].split('.')[0][3..-1]} #{size}]"
    end

    def name
      @raw.xpath('.//name[@type="primary"]').first.attr('value')
    end

    def description
      HTMLEntities.new.decode(@raw.xpath('.//description').first.text).strip
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

    def reimplementation?
      @raw.xpath('.//link[@type="boardgameimplementation" and @inbound="true"]').any?
    end

    def compilation?
      @raw.xpath('.//link[@type="boardgamecompilation" and @inbound="true"]').any?
    end

    def series?
      families.any? { |f| f.start_with?('Series: ') }
    end

    def integrates_with?
      @raw.xpath('.//link[@type="boardgameintegration"]').any?
    end

    def original_game?
      !integrates_with? && !series? && !compilation? && !reimplementation? && !families.any? { |f| f.start_with?("Game: ") }
    end

    def published?
      yearpublished != 0
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

    def designers
      @raw.xpath('.//link[@type="boardgamedesigner"]').map { |l| l.attr('value') }
    end

    def artists
      @raw.xpath('.//link[@type="boardgameartist"]').map { |l| l.attr('value') }
    end

    def publishers
      @raw.xpath('.//link[@type="boardgamepublisher"]').map { |l| l.attr('value') }
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

    def expansion?
      @raw.xpath('.//item').first.attr("type").value == "boardgameexpansion"
    end
  end
end

BggTools::Item.include(BggTools::Itemable)
