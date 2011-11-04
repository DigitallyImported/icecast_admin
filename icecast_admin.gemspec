# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "icecast_admin/version"

Gem::Specification.new do |s|
  s.name        = "icecast_admin"
  s.version     = Icecast::Admin::VERSION
  s.authors     = ["Nick Wilon"]
  s.email       = ["nick@di.fm"]
  s.homepage    = "https://github.com/AudioAddict/icecast_admin"
  s.summary     = %q{Ruby gem for Icecast server administration}
  s.description = %q{Performs operations like listing mounts, listing clients, and kicking}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "nokogiri"
end
