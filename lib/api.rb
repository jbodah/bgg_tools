require 'open3'
require 'nokogiri'
require 'set'

module BggTools
  module API
    class << self
      BASE = "https://boardgamegeek.com"

      def search_games_by_designer(designer_id:)
        paginate(page_size: 100) do |page|
          io = http_get "#{BASE}/search/boardgame/page/#{page}?advsearch=1&q=&include%5Bdesignerid%5D=#{designer_id}"
          root = Nokogiri::HTML(io)
          root.css('tr[@id=row_]')
        end
      end

      def download_guild_users(guild_id:)
        paginate(page_size: 25) do |page|
          io = http_get "#{BASE}/guild/members/#{guild_id}/page/#{page}", auth: true
          root = Nokogiri::HTML(io)
          root.css(".username").map do |node|
            node.css('a').inner_html
          end
        end
      end

      def download_ratings(user_id:)
        ratings = []
        paginate(page_size: 300) do |page|
          io = http_get "#{BASE}/collection/user/#{user_id}?rated=1&subtype=boardgame&page=#{page}"
          root = Nokogiri::HTML(io)
          ratings += root.xpath(".//tr[@id]")
          root.css('.collection_objectname')
        end
        ratings
      end

      def download_plays(user_id:, since:)
        paginate(page_size: 100) do |page|
          io = http_get "#{BASE}/xmlapi2/plays?username=#{user_id}&mindate=#{since}&page=#{page}"
          root = Nokogiri::XML(io)
          root.children[0].xpath(".//play")
        end
      end

      def paginate(page_size:, &blk)
        acc = []
        page = 1
        done = false
        until done == true
          slice = blk.call(page)
          done = true if slice.size != page_size
          page += 1
          acc += slice
        end
        acc
      end

      def download_thing(item_id:)
        out = http_get "#{BASE}/xmlapi2/thing?id=#{item_id}&stats=1"
        Nokogiri::HTML(out)
      end

      # def download_things(ids:)
      #   out = http_get "#{BASE}/xmlapi2/thing?id=#{ids.join(',')}"
      #   bulk = Nokogiri::HTML(out)
      #   bulk.css('item').map do |doc|
      #     thing = {}
      #     thing[:id] = doc.attr('id')
      #     # thing[:image_id] = File.basename(doc.css('thumbnail')[0].inner_html, ".*").sub('pic', '')
      #     thing[:name] = doc.xpath(".//name[@type='primary']")[0].attr('value')
      #     thing
      #   end
      # end

      def http_get(url, auth: false)
        BggTools::Cache.maybe_cache(url) do
          auth_args = []
          if auth
            auth_args = ["-H", "Authorization: GeekAuth #{BggTools::GeekAuth.get}"]
          end

          backoff = 1
          state = :not_done
          out = nil
          until state == :ok
            BggTools::Logger.debug "making req to #{url}"
            out, _, st = Open3.capture3("curl", *auth_args, url, err: "/dev/null")
            if out =~ /Rate limit exceeded/
              BggTools::Logger.debug "rate limit exceeded; backing off then retrying"
              sleep backoff
              backoff = backoff * 2
            elsif st.to_i != 0
              BggTools::Logger.debug "non-zero status; sleeping then retrying: #{st.to_i}"
              sleep backoff
            else
              state = :ok
            end
          end

          out
        end
      end

      def http_post_json(url, json:, auth: true)
        auth_args = []
        if auth
          auth_args = ["-H", "Authorization: GeekAuth #{BggTools::GeekAuth.get}"]
        end

        BggTools::Logger.debug "making req to #{url}"
        out, err, st = Open3.capture3("curl", "-X", "POST", "-d", json, *auth_args, url, err: "/dev/null")
        if out =~ /Rate limit exceeded/
          BggTools::Logger.debug "rate limit exceeded; backing off then retrying"
          sleep backoff
          backoff = backoff * 2
        elsif st.to_i != 0
          BggTools::Logger.debug "non-zero status; sleeping then retrying: #{st.to_i}"
          sleep backoff
        else
          return out
        end
      end
    end
  end
end
