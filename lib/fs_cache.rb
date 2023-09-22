require 'fileutils'
require 'digest/md5'

module BggTools
  class FSCache
    DEFAULT_ROOT = File.expand_path("../../.cache", __FILE__)

    def initialize(root: DEFAULT_ROOT)
      @root = root
      FileUtils.mkdir_p(root)
    end

    def key?(key)
      File.exist?(path_for(key))
    end

    def clear
      Dir[File.join(@root, "*")].each do |f|
        File.delete(f)
      end
    end

    def store(key, value)
      File.write(path_for(key), Marshal.dump(value))
    end

    def fetch(key)
      Marshal.load(File.read(path_for(key)))
    end

    private

    def path_for(key)
      digest = Digest::MD5.hexdigest(key)
      File.join(@root, digest)
    end
  end
end
