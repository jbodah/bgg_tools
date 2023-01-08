require 'logger'

module BggTools
  class Logger
    @logger = ::Logger.new($stdout)
    @logger.level = ::Logger::DEBUG

    class << self
      def method_missing(sym, *args, &blk)
        @logger.public_send(sym, *args, &blk)
      end
    end
  end
end
