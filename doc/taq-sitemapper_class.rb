require "rubygems"
require "taq-sitemapper"

data = [{url: "One"  , lastmod: Time.now, freq: "monthly", priority: 1}, 
        {url: "Two"  , lastmod: Time.now, freq: "monthly", priority: 1}, 
        {url: "Three", lastmod: Time.now, freq: "monthly", priority: 1}]

extra= [{url: "Four" , lastmod: Time.now, freq: "yearly", priority: 0.5}, 
        {url: "Five" , lastmod: Time.now, freq: "yearly", priority: 0.5}, 
        {url: "Six"  , lastmod: Time.now, freq: "yearly", priority: 0.5}]

sitemapper = SiteMapper::SiteMapper.new
sitemapper.loc  = :url
sitemapper.changefreq  = :freq
sitemapper.priority  = :priority
sitemapper.file = "/tmp/sitemap_class.xml"
sitemapper.url = "http://localhost.com/sitemap.xml"
sitemapper.write_sitemap(data.entries)

# extra data
sitemapper.file = "/tmp/sitemap_class_extra.xml"
sitemapper.write_sitemap(data.entries,extra.entries)
sitemapper.ping
