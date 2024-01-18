$: << File.expand_path("..", __FILE__)

module Env
  class << self
    def load_all
      Dir[File.expand_path("../lib/**/*", __FILE__)].each do |f|
        require f
      end
      load_once_env
      load_each_env
      :ok
    end

    def reload_all
      Dir[File.expand_path("../lib/**/*", __FILE__)].each do |f|
        load f
      end
      load_each_env
      :ok
    end

    def reauth
      if File.exist?('.geekauth')
        BggTools::GeekAuth.set(File.read('.geekauth').rstrip)
      end
    end

    private

    def load_once_env
      @cache = BggTools::FSCache.new
      BggTools::Cache.set_cache(@cache)
    end

    def load_each_env
      reauth

      if File.exist?('.collid')
        BggTools::Collection.set_collid(File.read('.collid').rstrip)
      end
    end
  end
end
