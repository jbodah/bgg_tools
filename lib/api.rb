require 'open3'
require 'nokogiri'
require 'set'
require 'net/http'

module BggTools
  module API
    class << self
      BASE = "https://boardgamegeek.com"
      MAX_PAGES = Float::INFINITY

      def search_games(max_pages: MAX_PAGES, designer_id: nil, no_expansions: true, min_avg_rating: nil, max_avg_rating: nil, min_voters: nil, family_id: nil, min_players: nil, max_players: nil, exclusive_player_count: false, min_year: nil, max_year: nil)
        params = ""
        params << "&include%5Bdesignerid%5D=#{designer_id}" if designer_id
        params << "&nosubtypes[]=boardgameexpansion" if no_expansions
        params << "&&floatrange%5Bavgrating%5D%5Bmin%5D=#{min_avg_rating}" if min_avg_rating
        params << "&floatrange%5Bavgrating%5D%5Bmax%5D=#{max_avg_rating}" if max_avg_rating
        params << "&range%5Bnumvoters%5D%5Bmin%5D=#{min_voters}" if min_voters
        params << "&familyids[0]=#{family_id}" if family_id
        params << "&range%5Bminplayers%5D%5Bmax%5D=#{min_players}" if min_players
        params << "&range%5Bmaxplayers%5D%5Bmin%5D=#{max_players}" if max_players
        params << "&playerrangetype=exclusive" if exclusive_player_count
        params << "&range%5Byearpublished%5D%5Bmin%5D=#{min_year}" if min_year
        params << "&range%5Byearpublished%5D%5Bmax%5D=#{max_year}" if max_year

        paginate(page_size: 100, max_pages: max_pages) do |page|
          io = http_get "#{BASE}/search/boardgame/page/#{page}?advsearch=1&q=#{params}"
          root = Nokogiri::HTML(io)
          root.css('tr[@id=row_]')
        end
      end

      def browse_games_by_rank(max_pages: MAX_PAGES)
        lazy_paginate(page_size: 100, max_pages: max_pages) do |page|
          io = http_get "#{BASE}/browse/boardgame/page/#{page}", auth: page > 20
          root = Nokogiri::HTML(io)
          root.css('tr[@id]').select { |css| css.attr('id') =~ /row_/ }
        end
      end

      def update_comment(item_id:, collid:, comment:)
        http_post "#{BASE}/geekcollection.php", data: "fieldname=comment&collid=#{collid}&objecttype=thing&objectid=#{item_id}&B1=Save&B1=Cancel&value=#{URI.encode(comment)}&ajax=1&action=savedata"
      end

      def download_list(list_id:)
        io = http_get "#{BASE}/xmlapi/geeklist/#{list_id}"
        Nokogiri::XML(io)
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
        end.to_a
        ratings
      end

      def download_prevowned(user_id:)
        prevowned = []
        paginate(page_size: 300) do |page|
          io = http_get "#{BASE}/collection/user/#{user_id}?prevowned=1&subtype=boardgame&page=#{page}"
          root = Nokogiri::HTML(io)
          prevowned += root.xpath(".//tr[@id]")
          root.css('.collection_objectname')
        end.to_a
        prevowned
      end

      def download_plays(user_id:, since:)
        paginate(page_size: 100) do |page|
          io = http_get "#{BASE}/xmlapi2/plays?username=#{user_id}&mindate=#{since}&page=#{page}"
          root = Nokogiri::XML(io)
          root.children[0].xpath(".//play")
        end
      end

      def lazy_paginate(page_size:, max_pages: MAX_PAGES, &blk)
        Enumerator.new do |y|
          acc = []
          page = 1
          done = false
          until done == true || page > max_pages
            slice = blk.call(page)
            slice.each { |element| y << element }
            done = true if slice.size != page_size
            page += 1
            acc += slice
          end
          acc
        end.lazy
      end

      def paginate(page_size:, max_pages: MAX_PAGES, &blk)
        acc = []
        page = 1
        done = false
        until done == true || page > max_pages
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

      def download_things(item_ids:)
        out = http_get "#{BASE}/xmlapi2/thing?id=#{item_ids.join(',')}&stats=1"
        Nokogiri::HTML(out)
      end

      def http_get(url, auth: false)
        BggTools::Cache.maybe_cache(url) do
          auth_args = []
          if auth
            auth_args = ["-H", "Authorization: GeekAuth #{BggTools::GeekAuth.get}"]
          end

          backoff = 1
          state = :not_done
          out = nil
          uri = URI(url)
          Net::HTTP.start(uri.host, uri.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
            until state == :ok
              BggTools::Logger.debug "making req to #{url}"

              req = Net::HTTP::Get.new(uri)
              req["Authorization"] = "GeekAuth #{BggTools::GeekAuth.get}" if auth

              res = http.request(req)

              case res.code.to_i
              when 429
                BggTools::Logger.debug "rate limit exceeded; backing off then retrying"
                sleep backoff
                backoff = backoff * 2
              when (200..299)
                out = res.body
                state = :ok
              when 302
                if res["location"].start_with?("/login")
                  BggTools::Logger.error "session expired!"
                  raise
                end

                BggTools::Logger.debug "unhandled 302 status; sleeping then retrying"
                BggTools::Logger.debug res["location"]
                sleep backoff
              when body =~ /try again later/
                BggTools::Logger.debug "async request is being processed; sleeping and retrying"
                sleep backoff
                backoff = backoff * 2
              else
                BggTools::Logger.debug "non-200 status; sleeping then retrying: #{res.code.to_i}"
                BggTools::Logger.debug res.body
                sleep backoff
              end
            end
          end

          out
        end
      end

      def http_post(url, data:, auth: true)
        auth_args = []
        if auth
          auth_args = ["-H", "Authorization: GeekAuth #{BggTools::GeekAuth.get}"]
        end

        BggTools::Logger.debug "making req to #{url}"
        out, err, st = Open3.capture3("curl", "-d", data, *auth_args, url, err: "/dev/null")
        puts out
        puts err
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
