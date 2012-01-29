# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "taq-sitemapper/version"

Gem::Specification.new do |s|
  s.name        = "taq-sitemapper"
  s.version     = SiteMapper::VERSION
  s.authors     = ["Eustaquio Rangel"]
  s.email       = ["eustaquiorangel@gmail.com"]
  s.homepage    = "https://github.com/taq/sitemapper"
  s.summary     = %q{Create a sitemap}
  s.description = %q{Create a sitemap with a data collection}

  s.rubyforge_project = "taq-sitemapper"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "nokogiri"
  s.add_runtime_dependency "builder" 
end
