# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sitemapper/version"

Gem::Specification.new do |s|
  s.name        = "sitemapper"
  s.version     = SiteMapper::VERSION
  s.authors     = ["Eustaquio Rangel"]
  s.email       = ["taq@eustaquiorangel.com"]
  s.homepage    = ""
  s.summary     = %q{Create a sitemap}
  s.description = %q{Create a sitemap with a data collection}

  s.rubyforge_project = "sitemapper"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "nokogiri"
  s.add_runtime_dependency "builder" 
end
