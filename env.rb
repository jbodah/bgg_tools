$: << File.expand_path("..", __FILE__)

module Env
  def self.load_all
    Dir[File.expand_path("../lib/**/*", __FILE__)].each do |f|
      require f
    end
  end

  def self.reload_all
    Dir[File.expand_path("../lib/**/*", __FILE__)].each do |f|
      load f
    end
  end
end
