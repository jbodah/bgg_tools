require 'logger'
require 'open3'
require 'nokogiri'
require 'set'

module BggTools
  module API
    class << self
      BASE = "https://boardgamegeek.com"
      LOGGER = Logger.new($stdout)
      LOGGER.level = Logger::DEBUG

      def download_ratings(user_id:)
        ratings = []
        page = 1
        done = false
        seen = Set.new
        until done == true
          io = curl "#{BASE}/collection/user/#{user_id}?rated=1&subtype=boardgame&page=#{page}"
          page += 1
          root = Nokogiri::HTML(io)
          page_size = root.css('.collection_objectname').size
          done = true if page_size != 300
          ratings += root.xpath(".//tr[@id]")
        end
        ratings
      end

      def download_plays(user_id:, since:)
        plays = []
        page = 1
        done = false
        until done == true
          io = curl "#{BASE}/xmlapi2/plays?username=#{user_id}&mindate=#{since}&page=#{page}"
          root = Nokogiri::XML(io)
          slice = root.children[0].xpath(".//play")
          done = true if slice.size != 100
          page += 1
          plays += slice
        end
        plays
      end

      # def download_plays(user_id:, since:)
      #   items_by_id = {}
      #   page = 1
      #   done = false
      #   until done == true
      #     io = curl "#{BASE}/xmlapi2/plays?user_id=#{user_id}&mindate=#{since}&page=#{page}"
      #     root = Nokogiri::XML(io)
      #     root = Node.new(root.children[0])
      #     plays = root.select("play")
      #     done = true if plays.size != 100
      #     page += 1
      #     plays.each do |play|
      #       item = play.find("item")
      #       players = play.find("players").select("player")
      #       my_play = players.find { |p| p["user_id"] == user_id }
      #       id = item["objectid"]
      #       items_by_id[id] ||=  {plays: 0, new: 0, id: id, name: item["name"]}
      #       items_by_id[id][:plays] += 1
      #       if my_play["new"] == "1"
      #         items_by_id[id][:new] = 1
      #       end
      #     end
      #   end
      #   items_by_id
      # end

      def download_thing(id:)
        thing = {}
        out = curl "#{BASE}/xmlapi2/thing?id=#{id}"
        doc = Nokogiri::HTML(out)
        thing[:id] = id
        thing[:image_id] = File.basename(doc.css('thumbnail')[0].inner_html, ".*").sub('pic', '')
        thing[:name] = doc.xpath(".//name[@type='primary']")[0].attr('value')
        thing
      end

      def download_things(ids:)
        out = curl "#{BASE}/xmlapi2/thing?id=#{ids.join(',')}"
        bulk = Nokogiri::HTML(out)
        bulk.css('item').map do |doc|
          thing = {}
          thing[:id] = doc.attr('id')
          # thing[:image_id] = File.basename(doc.css('thumbnail')[0].inner_html, ".*").sub('pic', '')
          thing[:name] = doc.xpath(".//name[@type='primary']")[0].attr('value')
          thing
        end
      end

      def curl(url)
        backoff = 1
        loop do
          LOGGER.debug "making req to #{url}"
          out, _, st = Open3.capture3("curl", url, err: "/dev/null")
          if out =~ /Rate limit exceeded/
            LOGGER.debug "rate limit exceeded; backing off then retrying"
            sleep backoff
            backoff = backoff * 2
          elsif st.to_i != 0
            sleep backoff
          else
            return out
          end
        end
      end
    end
  end
end
