require "rubygems"
require "taq-sitemapper"

data = [{url: "One"  , lastmod: Time.now, freq: "monthly", priority: 1}, 
        {url: "Two"  , lastmod: Time.now, freq: "monthly", priority: 1}, 
        {url: "Three", lastmod: Time.now, freq: "monthly", priority: 1}]

sitemapper = Sitemapper::Sitemapper.new
sitemapper.loc  = :url
sitemapper.file = "/tmp/sitemap_class.xml"
sitemapper.write_sitemap(data.entries)
