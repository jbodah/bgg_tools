$: << File.expand_path("..", __FILE__)

module Env
  def self.load_all
    Dir[File.expand_path("../lib/**/*", __FILE__)].each do |f|
      require f
    end
    if File.exists?('.geekauth')
      BggTools::GeekAuth.set(File.read('.geekauth').rstrip)
    end
  end

  def self.reload_all
    Dir[File.expand_path("../lib/**/*", __FILE__)].each do |f|
      load f
    end
    if File.exists?('.geekauth')
      BggTools::GeekAuth.set(File.read('.geekauth').rstrip)
    end
  end
end
