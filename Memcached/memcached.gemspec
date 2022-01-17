Gem::Specification.new do |s|

  s.name     = "memcached"
  s.version  = '0.0'
  s.authors  = ["Belen Carozo"]
  s.email    = ["belcarozo@gmail.com"]
  s.summary  = "Memcached server implementation"
  s.files    = Dir.chdir(File.expand_path(__dir__)) do
      `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
    end
  s.homepage = "https://github.com/belcarozo/Memcached.git"
  s.license  = "MIT"
  s.bindir        = "bin"
  s.executables   = ['mem_server.rb', 'mem_client.rb']
  s.require_paths = ["lib", "bin"]
 end