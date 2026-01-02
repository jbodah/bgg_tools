module BggTools
  class Cache
    class << self
      def maybe_cache(key, &blk)
        return blk.call if @cache.nil?

        if !@cache.key?(key) || overwrite?
          result = blk.call
          BggTools::Logger.debug("storing new key in cache: key=#{key.inspect}")
          @cache.store(key, result)
          result
        else
          BggTools::Logger.debug("serving key from cache: key=#{key.inspect}")
          @cache.fetch(key)
        end
      end

      def fetch(key)
        @cache.fetch(key)
      end

      def ignore(&blk)
        prev = @cache
        begin
          set_cache(nil)
          blk.call
        ensure
          set_cache(prev)
        end
      end

      def overwrite(&blk)
        @state = :overwrite
        blk.call
      ensure
        @state = nil
      end

      def set_cache(cache)
        @cache = cache
      end

      def clear
        return if @cache.nil?
        @cache.clear
      end

      private

      def overwrite?
        @state == :overwrite || ENV.key?('FORCE_UNCACHE')
      end
    end
  end
end
